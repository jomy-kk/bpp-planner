;; Test 4-Step ECG Processing Pipeline - NO R-PEAKS

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

;; Load domain and problem
(load "domain_extended.lisp")
(load "problem_4_step_no_rpeaks.lisp")

(format t "~%=== 4-Step Pipeline Test - NO R-PEAKS DETECTOR ===~%")
(format t "Testing type-compatible pipeline without problematic step~%~%")

(format t "Pipeline specification:~%")
(format t "1. Denoise (without bandpass filter - use combinations)~%")
(format t "2. Resample (to 128 Hz)~%") 
(format t "3. Extract HRV features (directly from signal)~%")
(format t "4. Aggregate features (mean)~%~%")

(format t "Expected type flow:~%")
(format t "signal → signal → features → scalar~%~%")

(format t "Key difference from 5-step:~%")
(format t "❌ REMOVED: R-peaks detection (signal → event)~%")
(format t "✅ DIRECT: HRV features from signal (signal → features)~%~%")

(format t "This should succeed because:~%")
(format t "- All type transitions are compatible~%")
(format t "- No event→signal mismatch~%")
(format t "- Multi-block step1 still works (lowpass + highpass)~%~%")

;; Attempt planning
(format t "Starting planning...~%")

(handler-case
  (let ((plan (find-plans 'ecg-4-step-no-rpeaks-problem :verbose 1)))
    (if plan
        (progn
          (format t "~%🎉 SUCCESS! Found type-compatible 4-step plan:~%~%")
          (let ((actions (first plan))
                (counter 1))
            (dolist (action actions)
              (when (not (numberp action))
                (format t "~2D. ~A~%" counter action)
                (incf counter))))
          (format t "~%✅ Type compatibility verified!~%"))
        (format t "~%❌ No plan found.~%")))
  (error (e)
    (format t "~%❌ Planning error: ~A~%" e)))

(format t "~%=== 4-Step Test Complete ===~%") 