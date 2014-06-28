# tm2deftheme

Convert TextMate/SublimeText .tmTheme to Emacs 24 deftheme .el

### Install

    gem install tm2deftheme

### Usage:

    tm2deftheme [options] [themefile.tmTheme]

    options:

        -f         ouput Emacs 24 deftheme to file
                   e.g. Birds of Paradise.tmTheme

                   becomes:

                   birds-of-paradise-theme.el

        -s         when used with -f silence output
        -o         when used with -f overwrite existing file

        --debug    debugging output

When run without options converted theme is sent to `STDOUT`

### Notes

Note that Emacs syntax highlighting is managed differently to
SublimeText / TextMate. Various Emacs modes provide additional
highlighing support, but `tm2deftheme` (currently) only maps to core
`font-lock` faces. So while things won't look like a one-to-one copy,
the results are still pretty good.

Linum, fringe and modeline colours are derived from the base foreground 
and background colors.  Support for [Rainbow Delimiters](http://www.emacswiki.org/emacs/RainbowDelimiters) 
is provided automatically.

The imported foreground colors which constrast most from the background 
are averaged, from this average colour, 9 tint colors are generated and
assigned to the `rainbow-delimiters-depth-n-face` collection.

I'll be adding additional support for `js3-mode`, git-gutter, flyspell, 
flymake, flycheck, isearch and more.

### Demo

See for yourself, here's a handful of converted themes, shown in their
original format (here rendered by the excellent
[http://tmtheme-editor.herokuapp.com/](http://tmtheme-editor.herokuapp.com/))
and then shown in Emacs 24 after conversion.

![](https://raw.githubusercontent.com/emacsfodder/tmtheme-to-deftheme/master/slides.gif)

### Dependencies

Ruby 1.9 or later required.

Development, clone and run `bundle install` in the project folder.
