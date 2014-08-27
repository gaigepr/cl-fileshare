(defpackage :cl-fileshare-system (:use :cl :asdf))
(in-package :cl-fileshare-system)

(defsystem cl-fileshare
  :name "cl-fileshare"
  :version "0.0"
  :author "Gaige Pierce-Raison"
  :description ""
  :depends-on (:hunchentoot
               :log4cl
               :trivial-shell)
  :components ((:file "package")
               (:file "server")

               ))
