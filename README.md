# tm2deftheme

Gem to convert a textmate (or SublimeText) tmTheme to Emacs deftheme

### Install

    gem install tm2deftheme

### Usage:

    tm2deftheme [path/filename.tmtheme] [options]

    options:

        -f   save to a file named {filename.tmtheme}-theme.el

             e.g. Birds of Paradise.tmTheme

             becomes:

                  birds-of-paradise-theme.el

    With no options output is sent to STDOUT

### Dependencies

Ruby 1.9+, install dependencies with bundler, run `bundle install` in
the project folder.
