(defpackage :cl-fileshare-system (:use :cl :asdf))
(in-package :cl-fileshare-system)

(defsystem cl-fileshare
  :name "cl-fileshare"
  :version "0.0"
  :author "Gaige Pierce-Raison"
  :description ""
  :depends-on (:cl-json
               :cl-fad
               :cl-mime
               :hunchentoot
               :log4cl
               :sb-concurrency
               :trivial-shell)
  :components ((:file "package")
               (:file "globals" :depends-on ("package"))
               (:file "index")
               (:file "server" :depends-on ("globals" "index"))
               ))
