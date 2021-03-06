(in-package :cl-fileshare)

(defun generate-index-page ()
  (let ((index-path
         (concatenate 'string
                      *share-root*
                      (subseq (hunchentoot:request-uri hunchentoot:*request*) 7)))
        (url-path (subseq (hunchentoot:request-uri hunchentoot:*request*) 6)))
    (log:debug (format nil "index-path: ~a url-path: ~a" index-path url-path))
    (with-output-to-string (stream)
      (html-template:fill-and-print-template
       #P"static/index.tmpl"
       (list :current-path url-path
             ;;:parent-path (namestring (truename (cl-fad:merge-pathnames-as-directory url-path "../")))
             :index
             (loop for entry in (index-directory index-path)
                collect
                  (let* ((path (concatenate 'string "/" (subseq
                                                         (cdr (assoc :path entry))
                                                         (length *share-root*))))
                         (name-match (cl-ppcre:all-matches "[^/]+/*$" path))
                         (name (subseq path (car name-match) (cadr name-match)))
                         (kind (cdr (assoc :kind entry)))
                         (name-link (if (string= kind "File")
                                        (format nil "/dl~a" path)
                                        (format nil "/share~a" path)))
                         (name-link-target (if (string= kind "File")
                                               "_blank"
                                               ""))
                         (file-type (cdr (assoc :fileType entry)))
                         (detail-type (cdr (assoc :detailType entry))))
                    (list :path path
                          :name name
                          :kind kind
                          :name-link name-link
                          :name-link-target name-link-target
                          :file-type file-type
                          :detail-type detail-type))))
       :stream stream))))

(defun download-file-or-directory ()
  (let ((path (concatenate 'string *share-root*
                           (subseq (hunchentoot:request-uri hunchentoot:*request*) 4))))
    (if (child-directory-p path *share-root*)
      (cond ((cl-fad:directory-exists-p path)
             (multiple-value-bind (output message status)
                 (trivial-shell:shell-command
                  (format nil "tar -cvf ~a~a.tar ~a"
                          "/tmp/fileshare/" "download" path))
               (if (eq status 0)
                   (hunchentoot:handle-static-file (format nil "~a~a"
                                                           "/tmp/fileshare/"
                                                           "download.tar"))
                   (log:debug (format nil "Failed ~a ~a ~a" output message status)))))
            ((cl-fad:file-exists-p path)
             (hunchentoot:handle-static-file path)))
      (hunchentoot:redirect "/share/"))))

(defun configure-logging (&key (log-file *log-file*))
  (if *debug*
      (log:config :all :sane :d :daily log-file)
      (log:config :all :sane :daily log-file)))

(defun start-fileshare ()
  (configure-logging)
  (setq hunchentoot:*session-max-time* (* 24 60 60)
        hunchentoot:*CATCH-ERRORS-P* t
        hunchentoot:*log-lisp-errors-p* t
        hunchentoot:*log-lisp-backtraces-p* t
        hunchentoot:*log-lisp-warnings-p* t
        hunchentoot:*lisp-errors-log-level* :debug
        hunchentoot:*lisp-warnings-log-level* :debug)
  (progn
    (push (hunchentoot:create-folder-dispatcher-and-handler
           "/static/" "~/lisp/cl-fileshare/static/")
          hunchentoot:*dispatch-table*)
    (push (hunchentoot:create-regex-dispatcher
           "^/share/" 'generate-index-page)
          hunchentoot:*dispatch-table*)
    (push (hunchentoot:create-regex-dispatcher
           "^/dl/" 'download-file-or-directory)
          hunchentoot:*dispatch-table*))
  (setq *fileshare-server*
        (make-instance
         'hunchentoot:easy-acceptor
         :port *fileshare-port*
         :access-log-destination "fileshare-access.log"
         :message-log-destination "fileshare-error.log"))
  (hunchentoot:start *fileshare-server*))

(defun stop-fileshare ()
  (when *fileshare-server*
    (hunchentoot:stop *fileshare-server* :soft t)))

(defun restart-fileshare ()
  (stop-fileshare)
  (start-fileshare))
