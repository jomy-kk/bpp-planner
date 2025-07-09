;; Test: 5-step pipeline without bandpass filter
;; Goal: Test domain flexibility when preferred block unavailable
;; Expected: Find alternative denoising blocks or fail gracefully

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

(load "domain_extended.lisp")
(load "problem_5_step_no_bandpass.lisp")

;; Run planning and display results
(let ((plans (find-plans 'ecg-5-step-no-bandpass-problem :verbose 1)))
  (when plans
    (format t "~%Plan found:~%")
    (dolist (action (first plans))
      (unless (numberp action)
        (format t "  ~A~%" action))))) 