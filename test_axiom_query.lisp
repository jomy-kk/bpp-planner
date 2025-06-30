;; Query for axioms
(require :asdf)
(ql:quickload "shop3")
(in-package :shop3)
(load "domain_extended.lisp")
(load "problem_bad_practice_aliasing.lisp")

;; Query for axioms that should be inferred
(shop3-prove '(bp-aliasing-risk step1 step2 ?cutoff ?sampling-rate) '(ecg-bad-practice-aliasing))
(shop3-prove '(bp-violation aliasing-risk ?step1 ?step2) '(ecg-bad-practice-aliasing))
(shop3-prove '(bp-violation-details aliasing-risk ?step1 ?step2 ?cutoff ?nyquist) '(ecg-bad-practice-aliasing)) 