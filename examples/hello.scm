
(import chicken scheme)

(use
 coops
 extras
 smoke
 qtcore
 qtgui)

(init-qtcore-smoke)
(init-qtgui-smoke)
(let* ((qtcore-binding (make-MySmokeBinding qtcore-smoke))
       (qtgui-binding (make-MySmokeBinding qtgui-smoke))
       (classid (find-class qtcore-smoke "QApplication"))
       (methid (find-method (ModuleIndex-smoke classid)
                            "QApplication" "QApplication$?"))
       (stack (make-stack 3))
       (qapp #f)
       (widget #f))
  (printf "QApplication classId: [~A, ~A], QApplication($?) methId: [~A, ~A]~%"
          (smoke-modulename (ModuleIndex-smoke classid))
          (ModuleIndex-index classid)
          (smoke-modulename (ModuleIndex-smoke methid))
          (ModuleIndex-index methid))
  (stack-set-int-pointer! stack 1 0) ;; &argc
  (stack-set-unsigned-long! stack 2 0) ;; argv
  (call-method (ModuleIndex-smoke methid) methid #f stack)
  (set! qapp (stack-pointer stack 0))
  ;; // method index 0 is always "set smoke binding" - needed for
  ;; // virtual method callbacks etc.
  (stack-set-pointer! stack 1 qtgui-binding)
  (call-method/classid+methidx
   (ModuleIndex-smoke classid) classid 0 qapp stack)

  ;; create a widget
  ;;
  (set! classid (find-class qtcore-smoke "QWidget"))
  (set! methid (find-method (ModuleIndex-smoke classid)
                            "QWidget" "QWidget"))
  (printf "QWidget classId: [~A, ~A], QWidget() methId: [~A, ~A]~%"
          (smoke-modulename (ModuleIndex-smoke classid))
          (ModuleIndex-index classid)
          (smoke-modulename (ModuleIndex-smoke methid))
          (ModuleIndex-index methid))
  (call-method (ModuleIndex-smoke methid) methid #f stack)
  (set! widget (stack-pointer stack 0))
  (stack-set-pointer! stack 1 qtgui-binding)
  (call-method/classid+methidx
   (ModuleIndex-smoke classid) classid 0 widget stack)

  ;; show the widget
  ;;
  (set! methid (find-method (ModuleIndex-smoke classid)
                            "QWidget" "show"))
  (printf "QWidget classId: [~A, ~A], show() methId: [~A, ~A]~%"
          (smoke-modulename (ModuleIndex-smoke classid))
          (ModuleIndex-index classid)
          (smoke-modulename (ModuleIndex-smoke methid))
          (ModuleIndex-index methid))
  (call-method (ModuleIndex-smoke methid) methid widget stack)

  ;; QApplication exec
  ;;
  (set! classid (find-class qtcore-smoke "QApplication"))
  (set! methid (find-method (ModuleIndex-smoke classid)
                            "QApplication" "exec"))
  (printf "QApplication classId: ~A, exec() methId: [~A, ~A]~%"
          (ModuleIndex-index classid)
          (smoke-modulename (ModuleIndex-smoke methid))
          (ModuleIndex-index methid))
  (call-method (ModuleIndex-smoke methid) methid #f stack)
  ;; we could get the integer return value from stack[0] here, too

  ;; destroy the QApplication instance
  ;;
  (set! methid (find-method qtgui-smoke "QApplication" "~QApplication"))
  (printf "QApplication classId: ~A, ~~QApplication() methId: [~A, ~A]~%"
          (ModuleIndex-index classid)
          (smoke-modulename (ModuleIndex-smoke methid))
          (ModuleIndex-index methid))
  (call-method (ModuleIndex-smoke methid) methid qapp stack)
  )
(delete-qtcore-smoke)
(delete-qtgui-smoke)