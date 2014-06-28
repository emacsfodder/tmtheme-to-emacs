#!/bin/sh

ls -d ~/.emacs.d/elpa/*-theme-140* -1 | xargs rm -rf
cd ~/workspace/tmtheme-to-deftheme
gem build -V tm2deftheme.gemspec
gem install -V -l tm2deftheme-*.gem
rm tm2deftheme-0.1.7.gem
cd ~/workspace/tmtheme-to-deftheme/generatedThemes

for a in ../sampleThemes/*.tmTheme
do
    tm2deftheme "$a" -f -o --debug
done

cd ~/workspace/tmtheme-to-deftheme
