
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

(let ((stack (make-stack 3))
      (classid #f)
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
  (stack-set-int-pointer! stack 1 0)     ;; &argc
  (stack-set-unsigned-long! stack 2 0)   ;; argv

  (let ((qapp (instantiate qtgui "QApplication" "QApplication$?" stack))
        (widget (instantiate qtgui "QWidget" "QWidget" stack)))

    ;; show the widget
    ;;
    (set! classid (find-class qtgui "QWidget"))
    (set! methid (find-method qtgui "QWidget" "show"))
    (printf "QWidget classId: [~A, ~A], show() methId: [~A, ~A]~%"
            (smoke-modulename (ModuleIndex-smoke classid))
            (ModuleIndex-index classid)
            (smoke-modulename (ModuleIndex-smoke methid))
            (ModuleIndex-index methid))
    (call-method qtgui methid widget stack)

    ;; QApplication exec
    ;;
    (set! classid (find-class qtgui "QApplication"))
    (set! methid (find-method qtgui "QApplication" "exec"))
    (printf "QApplication classId: ~A, exec() methId: [~A, ~A]~%"
            (ModuleIndex-index classid)
            (smoke-modulename (ModuleIndex-smoke methid))
            (ModuleIndex-index methid))
    (call-method-with-callbacks qtgui methid #f stack)
    (printf "QApplication exec() return value: ~A~%"
            (stack-int stack 0))

    ;; destroy the QApplication instance
    ;;
    (set! methid (find-method qtgui "QApplication" "~QApplication"))
    (printf "QApplication classId: ~A, ~~QApplication() methId: [~A, ~A]~%"
            (ModuleIndex-index classid)
            (smoke-modulename (ModuleIndex-smoke methid))
            (ModuleIndex-index methid))
    (call-method-with-callbacks qtgui methid qapp stack)))
