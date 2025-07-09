;; Test: 4-step pipeline validation
;; Goal: Validate pre-existing solution with assigned blocks
;; Expected: Configure parameters and connect steps for given block assignments

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

(load "domain_extended.lisp")
(load "problem_4_step_validation.lisp")

;; Run planning and display results
(let ((plans (find-plans 'ecg-4-step-validation-problem :verbose 1)))
  (when plans
    (format t "~%Plan found:~%")
    (dolist (action (first plans))
      (unless (numberp action)
        (format t "  ~A~%" action))))) 