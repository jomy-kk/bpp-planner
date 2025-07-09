;; Test: 4-step pipeline without R-peaks detection
;; Goal: Test type-compatible pipeline avoiding problematic signal->event transition
;; Expected: Direct signal->features flow, multi-block step1 (lowpass+highpass)

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

(load "domain.lisp")
(load "problem5.lisp")

;; Run planning and display results
(let ((plans (find-plans 'ecg-4-step-no-rpeaks-problem :verbose 1)))
  (when plans
    (format t "~%Plan found:~%")
    (dolist (action (first plans))
      (unless (numberp action)
        (format t "  ~A~%" action))))) 