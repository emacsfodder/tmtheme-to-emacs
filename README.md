# tmtheme-to-deftheme

Script to convert a textmate (or SublimeText) tmTheme to Emacs deftheme

Note: Seriously shoddy pre-Alpha version (however, works fine on the test Themes in `sampleThemes`)

### Usage:

    ruby tmtheme-to-deftheme.rb [path/filename.tmtheme] > [name-theme.el]

### Roadmap

1. Do palette interpolation to define various Emacs color faces, which
aren't included in the theme.

2. Fix to use a real template instead of HEREDOC

3. Fix codebase to be way less shonky, add tests

### Dependencies

Ruby 1.9+ and plist & color gems.

Fix dependencies with bundler, run `bundle install` in the project folder.
