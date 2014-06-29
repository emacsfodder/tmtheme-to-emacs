module TmthemeToDeftheme

  require 'plist4r'
  require 'color'
  require 'erubis'
  require 'yaml'

  class Main

    SCOPE_MAP   = YAML.load_file(File.join(File.dirname(__FILE__),'..','data','scopes-to-faces.yml'))
    TM_SCOPES   = SCOPE_MAP.map(&:first)
    EMACS_FACES = SCOPE_MAP.map{|a| a[1..-1]}

    def initialize theme_filename, options
      @theme_filename  = theme_filename
      @options         = options

      @plist           = Plist4r.open @theme_filename
      @author          = @plist["author"]
      @name            = @plist["name"]
      @theme_name      = "#{@plist["name"]}".downcase.tr ' _', '-'
      @long_theme_name = "#{@theme_name}-theme"

      if @options[:f]
        @deftheme_filename = "#{@long_theme_name}.el"
        unless @options[:s]
          $stderr.puts "Creating: #{@deftheme_filename}"
        end
        if File.exist? @deftheme_filename
          unless @options[:o]
            $stderr.puts "#{@deftheme_filename} already exists, use -o to force overwrite"
            exit 1
          end
        end
        File.open(@deftheme_filename, "w") {|f| f.puts parse}
      else
        puts parse
      end
    end

    def debug_out message
      $stderr.puts message if @options[:debug]
    end

    def map_scope scope
      if scope.index ","
        names = scope.split(",").map(&:strip)
        debug_out names
        first_match = names.map{|n| TM_SCOPES.find_index n}.compact.first
      else
        debug_out scope
        first_match = TM_SCOPES.find_index scope
      end

      if first_match.nil?
        nil
      else
        debug_out "#{first_match} :: #{scope} : #{EMACS_FACES[first_match]}"
        EMACS_FACES[first_match]
      end
    end

    def make_attr s, k
      debug_out "Make attrs: #{s[:face]} : #{k} : #{s} : #{s[k]}"
      ":#{k} \"#{s[k]}\"" if s[k]
    end

    def italic_underline_bold s
      if s["fontStyle"]
        s["fontStyle"].split(" ").map{|i| ":#{i} t" }.join " "
      end
    end

    def face_attrs s
      "#{make_attr s, "foreground"} #{make_attr s, "background"} #{italic_underline_bold s}"
    end

    def map_scope_to_emacs_face hash
      emacs_face = map_scope hash["scope"]
      return nil if emacs_face.nil?
      settings = hash["settings"]
      emacs_face = [emacs_face] unless emacs_face.class == Array
      mapped_scope = emacs_face.map{|face| {face: face, settings: settings, scope: hash["scope"]}}
      debug_out mapped_scope
      mapped_scope
    end

    def map_palette_key faces, key
      faces.map{|f| Color::RGB.from_html f[:settings][key] if f[:settings][key]}.compact
    end

    def isolate_palette faces
      [map_palette_key( faces, "foreground"), map_palette_key( faces, "background")]
    end

    def fix_rgba hexcolor
      if hexcolor.length == 9
        c = Color::RGB.from_html hexcolor[0,7]
        a = hexcolor[7,2].to_i(16).to_f
        p = (a / 255.0) * 100.0
        unless @base_bg.nil?
          c.mix_with(@base_bg, p).html
        else
          c.html
        end
      elsif hexcolor.length == 7 || hexcolor.length == 4
        hexcolor
      end
    end

    # Note: Foreground palette
    def palette_average_values sample_palette
      samples = sample_palette.map{|c|
        c = c.to_hsl
        {hue: c.hue, sat: c.saturation, lvl: c.brightness}
      }

      avg = {}
      avg[:hue] = samples.map{|s| s[:hue]}.reduce{|sum,c| sum + c} / samples.size
      avg[:sat] = samples.map{|s| s[:sat]}.reduce{|sum,c| sum + c} / samples.size
      avg[:lvl] = samples.map{|s| s[:lvl]}.reduce{|sum,c| sum + c} / samples.size

      {
        color: Color::HSL.new(avg[:hue], avg[:sat], avg[:lvl]).to_rgb,
        avg: avg,
        brightest: sample_palette.max_by(&:brightness),
        darkest: sample_palette.min_by(&:brightness),
        samples: samples
      }
    end

    def darktheme?
      !lighttheme?
    end

    def lighttheme?
      @base_bg.brightness > 0.45
    end

    def make_rainbow_parens
      samples = if lighttheme?
        @foreground_palette.sort_by{|c| c.brightness }.select{|c| c.brightness < 0.65 }
      else
        @foreground_palette.sort_by{|c| - c.brightness }.select{|c| c.brightness > 0.45 }
      end

      debug_out "- Palette sample -------------------------------"
      debug_out samples.map(&:html)
      debug_out "- <<<<<<<<<<<<<< -------------------------------"

      values = palette_average_values samples
      @average_foregroung_color = values[:color]
      @darkest_foregroung_color = values[:darkest]
      @brightest_foregroung_color = values[:brightest]
      rainbow_top = @average_foregroung_color.mix_with @darkest_foregroung_color, 30

      9.times.collect do |i|
        rainbow_top.adjust_brightness(i * 10).html
      end
    end

    def parse
      debug_out "= Converting : #{@theme_filename} =============================="
      debug_out "- tmTheme scope settings --------------------"
      debug_out @plist["settings"].to_yaml

      @base_settings   = @plist["settings"].first["settings"]
      @base_bg_hex     = fix_rgba @base_settings["background"]
      @base_bg         = Color::RGB.from_html @base_bg_hex
      @base_fg_hex     = fix_rgba @base_settings["foreground"]
      @base_fg         = Color::RGB.from_html @base_fg_hex

      @emacs_faces     = @plist["settings"].collect{|s| map_scope_to_emacs_face(s) if s["scope"] }.flatten.compact

      if lighttheme?
        debug_out "- Converting : Light Theme ----------------"
      else
        debug_out "- Converting : Dark Theme ----------------"
      end

      # Debug faces
      debug_out "- Mapped faces ------------------------------"

      # Fix any RGBA colors in the tmTheme
      @emacs_faces.each do |f|
        debug_out f.to_yaml
        f[:settings]["foreground"] = fix_rgba f[:settings]["foreground"] if f[:settings]["foreground"]
        f[:settings]["background"] = fix_rgba f[:settings]["background"] if f[:settings]["background"]
        debug_out f.to_yaml
      end

      @foreground_palette, @background_palette = isolate_palette @emacs_faces
      @rainbow_parens = make_rainbow_parens + ["#FF0000"]

      if @emacs_faces.select{|f| f[:face] == "font-lock-comment-face"}
        comment_face = @emacs_faces.select{|f| f[:face] == "font-lock-comment-face"}.first
        if comment_face
          @emacs_faces << {face: "font-lock-comment-delimiter-face", settings: comment_face[:settings]}
        end
      end

      render
    end

    def render
      Erubis::Eruby.new(
                        File.read(
                                  File.join(
                                            File.dirname(__FILE__),
                                            '..',
                                            'templates',
                                            'deftheme.erb.el'
                                            )))
        .result binding
    end

  end

end
