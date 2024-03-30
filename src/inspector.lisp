(in-package :learn-qt)
(in-readtable :qtools)

(define-widget primitive-frame (QTextEdit)
  ((value
    :initarg :value
    :initform (error "Must provide :value.")
    :accessor value)))

(define-initializer (primitive-frame setup)
  (setf (q+:text primitive-frame)
        (with-output-to-string (c)
          (describe (value primitive-frame) c))))

(define-widget list-frame (QListWidget)
  ((value
    :initarg :value
    :initform (error "Must provide :value.")
    :accessor value)))

(define-initializer (list-frame setup)
  (loop :for item :in (value list-frame)
        :do (q+:add-item list-frame (format nil "~a" item))))

(define-signal (list-frame selection) ())

(define-override (list-frame mouse-press-event) (ev)
  (call-next-qmethod)
  (signal! list-frame (selection)))

(defgeneric make-frame (value)
  (:method ((value t)) (make-instance 'primitive-frame :value value))
  (:method ((value list)) (make-instance 'list-frame :value value)))

(define-widget inspector (QWidget)
  ((value
    :initarg :value
    :initform nil
    :accessor value)
   (stack
    :initform nil
    :accessor stack)))

(define-initializer (inspector setup)
  (push (value inspector) (stack inspector)))

(define-subwidget (inspector crumbs) (q+:make-qlabel inspector)
  (setf (q+:text crumbs) (format nil "~a" (type-of (value inspector)))))

(define-subwidget (inspector pop) (q+:make-qpushbutton "Pop" inspector))

(define-subwidget (inspector frame) (make-frame (value inspector)))

(define-subwidget (inspector layout) (q+:make-qvboxlayout inspector)
  (q+:add-widget layout crumbs)
  (q+:add-widget layout pop)
  (q+:add-widget layout frame))

(define-signal (inspector stack-changed) ())

(define-slot (inspector push-list-item) ()
  (declare (connected frame (selection)))
  (print "gothere")
  (let ((value (elt (value frame) (q+:current-row frame))))
    (push value (stack inspector))
    (signal! inspector (stack-changed))))

(define-slot (inspector pop-item) ()
  (declare (connected pop (pressed)))
  (print (stack inspector))
  (setf (stack inspector) (cdr (stack inspector)))
  (signal! inspector (stack-changed)))

(define-slot (inspector stack-changed-handler) ()
  (declare (connected inspector (stack-changed)))
  (q+:close frame)
  (q+:close pop)
  (setf frame (make-frame (car (stack inspector))))
  (setf pop (q+:make-qpushbutton "Pop" inspector))
  (q+:add-widget layout pop)
  (q+:add-widget layout frame))
