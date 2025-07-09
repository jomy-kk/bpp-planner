;; Test: Best practices violation detection
;; Goal: Verify aliasing risk detection when lowpass frequency > Nyquist frequency
;; Expected: Plan includes !REPORT-ALIASING-RISK action for 60Hz lowpass + 100Hz sampling

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

(load "domain_extended.lisp")
(load "problem_bad_practice_aliasing.lisp")

;; Run planning and display results
(let ((plans (find-plans 'ecg-bad-practice-aliasing :verbose 1)))
  (when plans
    (format t "~%Plan found:~%")
    (dolist (action (first plans))
      (unless (numberp action)
        (format t "  ~A~%" action))))) 