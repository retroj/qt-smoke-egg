#! /bin/sh
#| -*- scheme -*-
exec csi -s $0 "$@"
|#

;;;
;;; Scheme implementation of hello.cpp from:
;;;   http://techbase.kde.org/Development/Languages/Smoke#hello.cpp
;;;

(import chicken scheme)

(use
 srfi-13
 coops
 extras
 smoke
 qtcore
 qtgui)

(define (click-test-handler method target . args)
  (let* ((binding (method-binding method))
         (smoke (slot-value binding 'smoke))
         (protected? (method-protected? method))
         (const? (method-const? method))
         (argtypes (method-args method)))
    (let ((sig (sprintf "~A~A~A(~A)"
                        (if protected? "protected " "")
                        (if const? "const " "")
                        (method-name method)
                        (string-join argtypes ", "))))
      (printf "~A(~A)::~A~%"
              (SchemeSmokeBinding-className
               (slot-value binding 'this)
               (method-classid method))
              target
              sig))))

(let ((classid #f)
      (methid #f))

  ;; print info about QApplication constructor
  ;;
  (let ((classid (find-class qtgui "QApplication"))
        (methid (find-method qtgui "QApplication" "QApplication$?")))
    (printf "QApplication classId: [~A, ~A], QApplication($?) methId: [~A, ~A]~%"
            (smoke-modulename (ModuleIndex-smoke classid))
            (ModuleIndex-index classid)
            (smoke-modulename (ModuleIndex-smoke methid))
            (ModuleIndex-index methid)))

  ;; print info about QWidget constructor
  ;;
  (let ((classid (find-class qtgui "QWidget"))
        (methid (find-method qtgui "QWidget" "QWidget")))
    (printf "QWidget classId: [~A, ~A], QWidget() methId: [~A, ~A]~%"
            (smoke-modulename (ModuleIndex-smoke classid))
            (ModuleIndex-index classid)
            (smoke-modulename (ModuleIndex-smoke methid))
            (ModuleIndex-index methid)))

  (run-with-qapplication
   `(("-widgetcount" "-bg" "#eccada"))
   (lambda (args)
     (printf "args: ~S~%" args)

     (let ((qapp (qapplication-instance)))
       (add-event-handler qapp "timerEvent" void)
       (call-method qtcore '("QObject" "startTimer$") qapp #f '((int 100))))

     ;; make a widget.
     ;;
     (let ((widget (instantiate qtgui "QWidget" "QWidget")))

       (add-event-handler widget "mousePressEvent" click-test-handler)
       (add-event-handler widget "mouseReleaseEvent" click-test-handler)

       ;; show the widget
       ;;
       (set! classid (find-class qtgui "QWidget"))
       (set! methid (find-method qtgui "QWidget" "show"))
       (printf "QWidget classId: [~A, ~A], show() methId: [~A, ~A]~%"
               (smoke-modulename (ModuleIndex-smoke classid))
               (ModuleIndex-index classid)
               (smoke-modulename (ModuleIndex-smoke methid))
               (ModuleIndex-index methid))
       (call-method qtgui methid widget)

       ;; QApplication exec (a static method)
       ;;
       (set! classid (find-class qtgui "QApplication"))
       (set! methid (find-method qtgui "QApplication" "exec"))
       (printf "QApplication classId: ~A, exec() methId: [~A, ~A]~%"
               (ModuleIndex-index classid)
               (smoke-modulename (ModuleIndex-smoke methid))
               (ModuleIndex-index methid))
       (let ((status (call-method-with-callbacks qtgui methid #f 'int)))
         (printf "QApplication exec() return value: ~A~%" status))

       ;; print info about QApplication destructor.  the instance gets
       ;; destroyed automatically by the surrounding `with-qapplication'
       ;; form.
       ;;
       (set! methid (find-method qtgui "QApplication" "~QApplication"))
       (printf "QApplication classId: ~A, ~~QApplication() methId: [~A, ~A]~%"
               (ModuleIndex-index classid)
               (smoke-modulename (ModuleIndex-smoke methid))
               (ModuleIndex-index methid))))))
