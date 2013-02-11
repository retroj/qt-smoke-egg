
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

(init-qtcore-smoke)
(init-qtgui-smoke)
(let* ((qtgui (make <SchemeSmokeBinding> 'smoke qtgui-smoke))
       (classid (find-class qtgui "QApplication"))
       (methid (find-method qtgui "QApplication" "QApplication$?"))
       (stack (make-stack 3))
       (qapp #f)
       (widget #f))
  (printf "QApplication classId: [~A, ~A], QApplication($?) methId: [~A, ~A]~%"
          (smoke-modulename (ModuleIndex-smoke classid))
          (ModuleIndex-index classid)
          (smoke-modulename (ModuleIndex-smoke methid))
          (ModuleIndex-index methid))
  (stack-set-int-pointer! stack 1 0)     ;; &argc
  (stack-set-unsigned-long! stack 2 0)   ;; argv
  (call-method qtgui methid #f stack)
  (set! qapp (stack-pointer stack 0))
  ;; // method index 0 is always "set smoke binding" - needed for
  ;; // virtual method callbacks etc.
  (stack-set-pointer! stack 1 (slot-value qtgui 'this))
  (call-method/classid+methidx
   (ModuleIndex-smoke classid) classid 0 qapp stack)

  ;; create a widget
  ;;
  (set! classid (find-class qtgui "QWidget"))
  (set! methid (find-method qtgui "QWidget" "QWidget"))
  (printf "QWidget classId: [~A, ~A], QWidget() methId: [~A, ~A]~%"
          (smoke-modulename (ModuleIndex-smoke classid))
          (ModuleIndex-index classid)
          (smoke-modulename (ModuleIndex-smoke methid))
          (ModuleIndex-index methid))
  (call-method qtgui methid #f stack)
  (set! widget (stack-pointer stack 0))
  (stack-set-pointer! stack 1 (slot-value qtgui 'this))
  (call-method/classid+methidx
   (ModuleIndex-smoke classid) classid 0 widget stack)

  ;; show the widget
  ;;
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
  (call-method/safe qtgui methid #f stack)
  (printf "QApplication exec() return value: ~A~%"
          (stack-int stack 0))

  ;; destroy the QApplication instance
  ;;
  (set! methid (find-method qtgui "QApplication" "~QApplication"))
  (printf "QApplication classId: ~A, ~~QApplication() methId: [~A, ~A]~%"
          (ModuleIndex-index classid)
          (smoke-modulename (ModuleIndex-smoke methid))
          (ModuleIndex-index methid))
  (call-method/safe qtgui methid qapp stack))
(delete-qtcore-smoke)
(delete-qtgui-smoke)
