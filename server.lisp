(in-package :cl-fileshare)

(hunchentoot:define-easy-handler (download-dir :uri "/download") ()
  (setf (hunchentoot:content-type*) "application/zip")
