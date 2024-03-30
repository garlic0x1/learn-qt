(in-package :learn-qt)
(in-readtable :qtools)

(define-widget prompt-entry (QLineEdit) ())

(define-signal (prompt-entry entry-changed) ())
(define-signal (prompt-entry return-pressed) ())
(define-signal (prompt-entry tab-pressed) ())

(define-override (prompt-entry focus-out-event) (ev)
  (q+:set-focus prompt-entry)
  (signal! prompt-entry (tab-pressed)))

(define-override (prompt-entry key-press-event) (ev)
  (flet ((submit-event-p (ev)
           (or (= (q+:key ev) (q+:qt.key_enter))
               (= (q+:key ev) (q+:qt.key_return)))))
    (cond ((submit-event-p ev)
           (signal! prompt-entry (return-pressed)))
          (t
           (call-next-qmethod)
           (signal! prompt-entry (entry-changed))))))

(define-widget prompt (QWidget)
  ((message
    :initarg :message
    :initform nil
    :accessor message)
   (completion
    :initarg :completion
    :initform nil
    :accessor completion)
   (entry
    :initarg :init-entry
    :initform ""
    :accessor entry)
   (callback
    :initarg :callback
    :initform (lambda (x) (declare (ignore x)) (warn "No callback."))
    :accessor callback)))

(define-subwidget (prompt completion-list) (q+:make-qlistwidget prompt)
  (loop :for it :in (funcall (completion prompt) (entry prompt))
        :do (q+:add-item completion-list it)))

(define-subwidget (prompt entry-field) (make-instance 'prompt-entry)
  (setf (q+:text entry-field) (entry prompt)))

(define-subwidget (prompt message-field) (q+:make-qlabel prompt)
  (when (message prompt)
    (setf (q+:text message-field) (message prompt))))

(define-subwidget (prompt layout) (q+:make-qvboxlayout prompt)
  (when (message prompt)
    (q+:add-widget layout message-field))
  (q+:add-widget layout completion-list)
  (q+:add-widget layout entry-field))

(define-slot (prompt enter) ()
  (declare (connected entry-field (return-pressed)))
  (when (callback prompt)
    (funcall (callback prompt) (entry prompt))))

(defun next-trie (listwidget)
  (str:common-prefix
   (loop :for i :from 0 :to (1- (q+:count listwidget))
         :collect (q+:text (q+:item listwidget i)))))

(define-slot (prompt completion-event) ()
  (declare (connected entry-field (tab-pressed)))
  (setf (q+:text entry-field) (next-trie completion-list))
  (signal! entry-field (entry-changed)))

(define-slot (prompt update-completion) ()
  (declare (connected entry-field (entry-changed)))
  (q+:clear completion-list)
  (setf (entry prompt) (q+:text entry-field))
  (loop :for it :in (funcall (completion prompt) (q+:text entry-field))
        :do (q+:add-item completion-list it)))
