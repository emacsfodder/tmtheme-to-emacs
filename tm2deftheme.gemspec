# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'tm2deftheme/version'

Gem::Specification.new do |s|
  s.name        = "tm2deftheme"
  s.version     = TmthemeToDeftheme::VERSION
  s.date        = "2014-06-28"
  s.summary     = "Convert .tmTheme to Emacs 24 deftheme .el"
  s.description = "Convert TextMate/SublimeText .tmTheme to Emacs 24 deftheme .el"
  s.authors     = ["Jason Milkins"]
  s.email       = ["jasonm23@gmail.com"]
  s.files       = Dir['lib/*.rb'] + Dir['data/*'] + Dir['bin/*'] + Dir['templates/*'] + %W(README.md LICENSE)
  s.homepage    = "https://github.com/emacsfodder/tmtheme-to-deftheme"
  s.license     = "GPL3"

  #Runtime Dependencies
  s.required_ruby_version = ">= 1.9.3"
  s.add_runtime_dependency "plist4r", '~> 1.2', '>= 1.2.2'
  s.add_runtime_dependency "color", "~> 1.7"
  s.add_runtime_dependency "slop", '~> 3.5', '>= 3.5.0'
  s.add_runtime_dependency "erubis", '~> 2.7', '>= 2.7.0'

  #Development dependencies
  # s.add_development_dependency "rspec"
  # spec.add_development_dependency "aruba"

  #Scripts available after instalation
  s.executables  = ["tm2deftheme"]
end
