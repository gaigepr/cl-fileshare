(defpackage :cl-fileshare-system (:use :cl :asdf))
(in-package :cl-fileshare-system)

(defsystem cl-fileshare
  :name "cl-fileshare"
  :version "1.0"
  :author "Gaige Pierce-Raison"
  :description ""
  :depends-on (:cl-fad
               :cl-json
               :cl-mime
               :html-template
               :hunchentoot
               :log4cl
               :trivial-shell)
  :components ((:file "package")
               (:file "globals" :depends-on ("package"))
               (:file "index")
               (:file "server" :depends-on ("globals" "index"))
               ))
