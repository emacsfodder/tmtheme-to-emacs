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

### Dependencies

Ruby 1.9 or later required.

Development, clone and run `bundle install` in the project folder.
