(in-package :learn-qt)
(in-readtable :qtools)

(define-widget counter-widget (QWidget)
  ())

(define-subwidget (counter-widget label) (q+:make-qlineedit counter-widget)
  (setf (q+:text label) "0"))

(define-subwidget (counter-widget increment)
    (q+:make-qpushbutton "Increment" counter-widget))

(define-subwidget (counter-widget decrement)
    (q+:make-qpushbutton "Decrement" counter-widget))

(define-subwidget (counter-widget layout) (q+:make-qvboxlayout counter-widget)
  (q+:add-widget layout label)
  (q+:add-widget layout increment)
  (q+:add-widget layout decrement))

(define-signal (counter-widget label-set) (int))

(define-slot (counter-widget increment) ()
  (declare (connected increment (pressed)))
  (declare (connected increment (return-pressed)))
  (signal! counter-widget (label-set int) (1+ (parse-integer (q+:text label)))))

(define-slot (counter-widget decrement) ()
  (declare (connected decrement (pressed)))
  (declare (connected decrement (return-pressed)))
  (signal! counter-widget (label-set int) (1- (parse-integer (q+:text label)))))

(define-slot (counter-widget label-set) ((new-val int))
  (declare (connected counter-widget (label-set int)))
  (setf (q+:text label) (format nil "~a" new-val)))
