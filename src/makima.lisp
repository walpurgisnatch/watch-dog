(defpackage makima
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.heart
        :makima.sentry
        :makima.html-watcher
        :makima.predicates
        :makima.handlers)
  (:import-from :postmodern
                :execute
                :query
                :dao-table-definition)
  (:export :main
           :setup
           :records-tablep
           :create-records-table))

(in-package :makima)


(defun setup ()
  (parse-settings *vars-file*)
  (ensure-tables-exists '(watcher handler predicate action record))
  (read-watchers)
  (pero:logger-setup "~/makima-logs")
  (pero:create-template "logs" '(:log "~a"))
  (pero:create-template "errors"
                        '(:download-error "Error while downloading page [~a]~%~a~%")
                        '(:error "ERROR~%~a~%"))
  (pero:create-template "content"
                        '(:changes "~a | was updated  with content [~a]")
                        '(:trigger "~a | triggered by value [~a]")
                        '(:created "~a | was created with content [~a]"))
  (pero:create-template "files" '(:file "~a | event was triggered"))
  (pero:create-template "pages" '(:updated "~a | Was updated")))

(setup)

(defun main (&optional (sleep-time 1))
  ;; (makima.daemon:daemonize :exit-parent t)
  (setup)
  (loop while *heartbeat* do
    (with-connection '("makima" "makima" "makima" "localhost")
      (beat)))
  ;; (makima.daemon:exit)
  )
