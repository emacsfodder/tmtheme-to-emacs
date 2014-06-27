module TmthemeToDeftheme

  require 'plist4r'
  require 'color'
  require 'erubis'
  require 'yaml'

  class Main

    SCOPE_MAP = YAML.load_file(File.join(File.dirname(__FILE__),'scopes-to-faces.yml'))
    TM_SCOPES = SCOPE_MAP.map(&:first)
    EMACS_FACES = SCOPE_MAP.map(&:last)

    def initialize theme_filename, options={}
      @plist = Plist4r.open theme_filename

      rendered_theme = convert

      if options[:f]
        deftheme_filename = "#{@long_theme_name}.el"
        unless options[:s]
          $stderr.puts "Converting #{theme_filename} to #{deftheme_filename}"
        end
        if File.exist? deftheme_filename
          unless options[:o]
            $stderr.puts "#{deftheme_filename} already exists, use -o to force overwrite"
            exit 1
          end
        end
        File.open(deftheme_filename, "w") {|f| f.puts rendered_theme}
      else
        puts rendered_theme
      end
    end

    def lookup_scope scope
      if scope.index(",")
        names = scope.split(",").map(&:strip)
        first_match = names.map{|n| TM_SCOPES.find_index n }.compact.first
      else
        first_match = TM_SCOPES.find_index(scope)
      end
      if first_match.nil?
        nil
      else
        EMACS_FACES[first_match]
      end
    end

    def has_face
    end

    def make_attr(s, k)
      ":#{k} \"#{s[k]}\"" if s[k]
    end

    # TODO: Extend to allow more attributes (bold, italic etc.)
    # Check what tmTheme allows.

    def face_attrs(s)
      "#{make_attr(s, "foreground")} #{make_attr(s, "background")}"
    end

    def map_scope_to_emacslisp(hash)
      emacs_face = lookup_scope hash["scope"]
      settings = hash["settings"]
      return nil if emacs_face.nil?
      {face: emacs_face, settings: settings}
    end

    def isolate_palette faces
      [
       faces.map{|f| # foreground colors
         Color::RGB.from_html f[:settings]["foreground"] if f[:settings]["foreground"]
       }.compact,
       faces.map{|f| # background colors
        Color::RGB.from_html f[:settings]["background"] if f[:settings]["background"]
       }.compact
      ]
    end

    def fix_rgba hexcolor
      if hexcolor.length == 9
        c = Color::RGB.from_html(hexcolor[0,7])
        a = hexcolor[7,2].to_i(16).to_f
        p = (a / 255.0) * 100.0
        c.mix_with(@base_bg, p).html
      elsif hexcolor.length == 7
        Color::RGB.from_html(hexcolor).html
      end
    end

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

    def make_rainbow_parens
      samples = if @base_bg.brightness > 0.45
        @foreground_palette.sort_by{|c| c.brightness }.select{|c| c.brightness < 0.30 }
      else
        @foreground_palette.sort_by{|c| - c.brightness }.select{|c| c.brightness > 0.45 }
      end

      values = palette_average_values(samples)
      average_color = values[:color]
      darkest = values[:darkest]
      rainbow_top = average_color.mix_with(darkest, 30)

      9.times.collect do |i|
        rainbow_top.adjust_brightness(i * 10).html
      end
    end

    def convert

      @base_settings = @plist["settings"][0]["settings"]
      @author = @plist["author"]
      @name = @plist["name"]
      @theme_name = "#{@plist["name"]}".downcase.tr(' _', '-')
      @long_theme_name = "#{@theme_name}-theme"
      @emacs_faces = @plist["settings"].collect{|s| map_scope_to_emacslisp(s) if s["scope"] }.compact
      @base_bg = Color::RGB.from_html @base_settings["background"]
      @base_fg = Color::RGB.from_html @base_settings["foreground"]

      # Fix any RGBA colors in the tmTheme
      @emacs_faces.each do |f|
        f[:settings]["foreground"] = fix_rgba f[:settings]["foreground"] if f[:settings]["foreground"]
        f[:settings]["background"] = fix_rgba f[:settings]["background"] if f[:settings]["background"]
      end

      @foreground_palette, @background_palette = isolate_palette @emacs_faces
      @rainbow_parens = make_rainbow_parens + ["#FF0000"]

      if @emacs_faces.select{|f| f[:face] == "font-lock-comment-face"}
        comment_face = @emacs_faces.select{|f| f[:face] == "font-lock-comment-face"}[0]
        if comment_face
          @emacs_faces << {face: "font-lock-comment-delimiter-face", settings: comment_face[:settings]}
        end
      end

      return render
    end

    def render
      Erubis::Eruby.new(File.read(File.join(File.dirname(__FILE__),'..','templates','deftheme.eruby'))).result(binding())
    end

  end

end
