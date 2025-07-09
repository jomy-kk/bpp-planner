;; Test: 5-step biosignal processing pipeline  
;; Goal: Verify complete pipeline planning with block selection and parameter configuration
;; Expected: Choose correct blocks from 22 available options and configure all parameters

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

(load "domain_.lisp")
(load "problem2.lisp")

;; Run planning and display results
(let ((plans (find-plans 'ecg-5-step-problem :verbose 1)))
  (when plans
    (format t "~%Plan found:~%")
    (dolist (action (first plans))
      (unless (numberp action)
        (format t "  ~A~%" action))))) 