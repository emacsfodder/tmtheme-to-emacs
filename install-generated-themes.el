;; Dirt simple loop loading of generated themes
(mapc
 #'(lambda (f)
     (message "Installing,,, %s" f)
     (package-install-file f))
 (directory-files "./generatedThemes/" t ".*-theme\\.el" ))
