
;;;
;;; Scheme implementation of hello.cpp from:
;;;   http://techbase.kde.org/Development/Languages/Smoke#hello.cpp
;;;

(import chicken scheme)

(use
 coops
 extras
 smoke
 qtcore
 qtgui)

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

  ;; make application and widget objects.  QApplication takes two args,
  ;; pointers to argc and argv.
  ;;
  (let ((qapp (instantiate qtgui "QApplication" "QApplication$?"
                           '(((c-pointer int) 0)  ;; &argc
                             (unsigned-long 0)))) ;; argv
        (widget (instantiate qtgui "QWidget" "QWidget")))

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

    ;; QApplication exec
    ;;
    (set! classid (find-class qtgui "QApplication"))
    (set! methid (find-method qtgui "QApplication" "exec"))
    (printf "QApplication classId: ~A, exec() methId: [~A, ~A]~%"
            (ModuleIndex-index classid)
            (smoke-modulename (ModuleIndex-smoke methid))
            (ModuleIndex-index methid))
    (let ((stack (make-smoke-stack 1)))
      (call-method-with-callbacks qtgui methid #f stack)
      (printf "QApplication exec() return value: ~A~%"
              (smoke-stack-int stack 0)))

    ;; destroy the QApplication instance
    ;;
    (set! methid (find-method qtgui "QApplication" "~QApplication"))
    (printf "QApplication classId: ~A, ~~QApplication() methId: [~A, ~A]~%"
            (ModuleIndex-index classid)
            (smoke-modulename (ModuleIndex-smoke methid))
            (ModuleIndex-index methid))
    (call-method-with-callbacks qtgui methid qapp)))
