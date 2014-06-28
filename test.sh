#!/bin/sh

ls -d ~/.emacs.d/elpa/*-theme-140* -1 | xargs rm -rf
cd ~/workspace/tmtheme-to-deftheme
gem build -V tm2deftheme.gemspec && gem install -V -l tm2deftheme-0.1.5.gem
cd ~/workspace/tmtheme-to-deftheme/generatedThemes
for a in ../sampleThemes/*.tmTheme
do
    tm2deftheme "$a" -f -o
done
cd ~/workspace/tmtheme-to-deftheme
