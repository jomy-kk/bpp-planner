;; Test Solution Validation
;; Tests if the planner can validate a pre-existing solution

(load "problem_4_step_validation.lisp")

;; Ensure we're in the SHOP3 package 
(in-package :shop3)

(format t "~%🎯 VALIDATION RESULT:~%")
(handler-case
  (let ((plan (find-plans 'ecg-4-step-validation-problem :verbose 1)))
    (if plan
        (progn
          (format t "~%✅ SUCCESS! The planner validated the pre-existing solution!~%~%")
          (format t "Validation plan actions:~%")
          (let ((actions (first plan))
                (counter 1))
            (dolist (action actions)
              (when (not (numberp action))
                (format t "~2D. ~A~%" counter action)
                (incf counter))))
          (format t "~%✅ Solution is VALID! All constraints satisfied.~%"))
        (format t "~%❌ FAILED! Could not validate the solution.~%")))
  (error (e)
    (format t "~%❌ Validation error: ~A~%" e)))

(format t "~%=== VALIDATION TEST COMPLETE ===~%") 