# tm2deftheme

Convert TextMate/SublimeText .tmTheme to Emacs 24 deftheme

### Install

    gem install tm2deftheme

### Usage:

    tm2deftheme [path/filename.tmtheme] [options]

    options:

        -f   save to a file named {filename}-theme.el

             e.g. Birds of Paradise.tmTheme

             becomes:

                  birds-of-paradise-theme.el

When run without options output goes to `STDOUT`

### Dependencies

For normal use, Ruby 1.9 or later, required.

For development, clone and install dependencies with bundler, run
`bundle install` in the project folder.
