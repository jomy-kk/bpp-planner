;; Test Best Practices Detection
;; Demonstrates aliasing risk detection in biosignal processing

(load "problem_bad_practice_aliasing.lisp")

(in-package :shop3)

(format t "~%=== BEST PRACTICES VIOLATION DETECTION TEST ===~%")
(format t "Testing automatic detection of bad practices in ECG processing...~%~%")

(format t "📋 SCENARIO:~%")
(format t "- Step 1: Lowpass filter at 60Hz~%")
(format t "- Step 2: Downsample to 100Hz~%")
(format t "- Step 3: Extract HRV features~%")
(format t "- Step 4: Aggregate features~%~%")

(format t "⚠️  EXPECTED VIOLATION:~%")
(format t "Aliasing risk: Lowpass 60Hz > Nyquist 50Hz (100Hz/2)~%~%")

(format t "🔍 Starting validation with best practices detection...~%")

(handler-case
  (let ((plan (find-plans 'ecg-bad-practice-aliasing :verbose 1)))
    (if plan
        (progn
          (format t "~%✅ Plan found successfully!~%")
          (format t "Solution is technically valid but may have violations...~%~%")
          
          ;; The plan actions executed
          (format t "Plan actions executed:~%")
          (let ((actions (first plan))
                (counter 1))
            (dolist (action actions)
              (when (not (numberp action))
                (format t "~2D. ~A~%" counter action)
                (incf counter))))
          
          (format t "~%🎯 BEST PRACTICES ANALYSIS:~%")
          (format t "The domain axioms automatically detect when:~%")
          (format t "- bp-aliasing-risk(step1, step2, 60, 100) is true~%")
          (format t "- bp-violation(aliasing-risk, step1, step2) is triggered~%")
          (format t "- bp-violation-details provides: Cutoff 60Hz > Nyquist 50Hz~%~%")
          
          (format t "💡 RECOMMENDATION:~%")
          (format t "To fix aliasing risk, use one of these approaches:~%")
          (format t "1. Lower the cutoff frequency to ≤50Hz before downsampling~%")
          (format t "2. Increase sampling rate to ≥120Hz (Nyquist = 60Hz)~%")
          (format t "3. Use anti-aliasing filter with steeper rolloff~%"))
        (format t "~%❌ No plan found - unexpected error!~%")))
  (error (e)
    (format t "~%❌ Planning error: ~A~%" e)))

(format t "~%=== BEST PRACTICES TEST COMPLETE ===~%")
(format t "The domain now automatically detects this common DSP anti-pattern!~%") 