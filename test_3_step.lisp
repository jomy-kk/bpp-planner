;; Test: 3-step biosignal processing pipeline
;; Goal: Verify domain handles different pipeline lengths (3 vs 5 steps)
;; Expected: Different block choices due to different step purposes

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

(load "domain_extended.lisp")
(load "problem_3_step.lisp")

;; Run planning and display results
(let ((plans (find-plans 'biosignal-3-step-problem :verbose 1)))
  (when plans
    (format t "~%Plan found:~%")
    (dolist (action (first plans))
      (unless (numberp action)
        (format t "  ~A~%" action))))) 