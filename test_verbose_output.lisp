;; Verbose planner test
(require :asdf)
(ql:quickload "shop3")
(in-package :shop3)
(load "domain_extended.lisp")
(load "problem_bad_practice_aliasing.lisp")

;; Run with maximum verbosity
(find-plans 'ecg-bad-practice-aliasing :verbose 3) 