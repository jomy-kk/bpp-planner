;; Test 5-Step ECG Processing Pipeline

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

;; Load domain and problem
(load "domain_extended.lisp")
(load "problem_5_step.lisp")

(format t "~%=== Generic Pipeline Test (Currently 5-Step) ===~%")
(format t "Domain now handles arbitrary pipeline lengths via recursion~%~%")

(format t "Pipeline specification:~%")
(format t "1. Denoise (bandpass 0.5-45 Hz)~%")
(format t "2. Resample (to 128 Hz)~%") 
(format t "3. Detect R-peaks~%")
(format t "4. Extract HRV features~%")
(format t "5. Aggregate features (mean)~%~%")

(format t "Challenge: Choose from ALL 22 blocks in KB:~%")
(format t "- 4 filters (bandpass, notch, lowpass, highpass)~%")
(format t "- 2 temporal detectors (r_peak, p_wave)~%")
(format t "- 2 feature extractors (hrv, generic)~%")
(format t "- 2 ML blocks (svm_classifier, svm_regressor)~%")
(format t "- 12 other blocks with various purposes~%~%")

(format t "Test: Can planner choose correct blocks from many options?~%")
(format t "Test: Will ALL parameters be configured (not just first)?~%")
(format t "Test: Does domain handle arbitrary pipeline length generically?~%~%")

;; Attempt planning
(format t "Starting planning...~%")

(handler-case
  (let ((plan (find-plans 'ecg-5-step-problem :verbose 1)))
    (if plan
        (progn
          (format t "~%🎉 SUCCESS! Found complete 5-step plan:~%~%")
          (let ((actions (first plan))
                (counter 1))
            (dolist (action actions)
              (when (not (numberp action))
                (format t "~2D. ~A~%" counter action)
                (incf counter)))))
        (format t "~%❌ No plan found.~%")))
  (error (e)
    (format t "~%❌ Planning error: ~A~%" e)))

(format t "~%=== 5-Step Test Complete ===~%") 