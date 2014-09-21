(in-package :cl-fileshare)

(hunchentoot:define-easy-handler (listing :uri "/") ()
  (setf (hunchentoot:content-type*) "application/json")
  (remove "\\"
          (json:encode-json-alist-to-string (index-directory "/home/gaige/Dropbox"))
          :test 'string=))

(hunchentoot:define-easy-handler (download-dir :uri "/download") ()
  ;(setf (hunchentoot:content-type*) "application/zip")
  ;(cond ((cl-fad:directory-exists-p "path/to/dir"))
  ;((cl-fad:file-exists-p "path/to/file")))
  (hunchentoot:handle-static-file
   (format nil "~a" (cdr (assoc "file" (hunchentoot:get-parameters* hunchentoot:*request*) :test #'string=)))))

(defun configure-logging (&key (log-file *log-file*))
  (if *debug*
      (log:config :all :sane :d :daily log-file)
      (log:config :all :sane :daily log-file)))

(defun start-fileshare ()
  (setq hunchentoot:*session-max-time* (* 24 60 60)
        hunchentoot:*CATCH-ERRORS-P* t
        hunchentoot:*log-lisp-errors-p* t
        hunchentoot:*log-lisp-backtraces-p* t
        hunchentoot:*log-lisp-warnings-p* t
        hunchentoot:*lisp-errors-log-level* :debug
        hunchentoot:*lisp-warnings-log-level* :debug)
  (push (hunchentoot:create-prefix-dispatcher "/home/gaige/lisp/" 'render-directory)
        hunchentoot:*dispatch-table*)
  (setq *file-server*
        (make-instance
         'hunchentoot:easy-acceptor
         :port *file-port*
         :access-log-destination "fileshare-access.log"
         :message-log-destination "fileshare-error.log"))
  (hunchentoot:start *file-server*))

(defun stop-fileshare ()
  (when *file-server*
    (hunchentoot:stop *file-server* :soft t)))
