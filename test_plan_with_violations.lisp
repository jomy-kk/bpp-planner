;; Test to see plan with violations
(require :asdf)
(ql:quickload "shop3")
(in-package :shop3)
(load "domain_extended.lisp")
(load "problem_bad_practice_aliasing.lisp")

;; Get plans with details
(setf *plans* (find-plans 'ecg-bad-practice-aliasing :verbose 2))
(format t "~%~%=== PLAN OUTPUT ===~%")
(pprint *plans*) 