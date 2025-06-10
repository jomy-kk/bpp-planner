;; Test 5-Step Pipeline WITHOUT Bandpass Filter

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

;; Load domain and modified problem
(load "domain_extended.lisp")
(load "problem_5_step_no_bandpass.lisp")

(format t "~%=== 5-Step Pipeline Test - NO BANDPASS FILTER ===~%")
(format t "Testing domain flexibility when obvious choice is unavailable~%~%")

(format t "Problem: IDENTICAL to original 5-step, BUT:~%")
(format t "❌ bandpass_filter REMOVED from available blocks~%")
(format t "🎯 Step1 still wants: denoising with low_freq=0.5, high_freq=45.0~%~%")

(format t "Available denoising blocks:~%")
(format t "- notch_filter (has notch_freq, quality_factor - different params)~%")
(format t "- lowpass_filter (has low_freq, filter_order - partial match)~%")
(format t "- highpass_filter (has high_freq, filter_order - partial match)~%")
(format t "- median_filter (has window_size, window_overlap - no freq params)~%")
(format t "- emd (has num_modes, stopping_criteria - no freq params)~%~%")

(format t "Key Questions:~%")
(format t "1. Will planner find alternative denoising block?~%")
(format t "2. How will it handle low_freq + high_freq constraints?~%")
(format t "3. Will it choose based on parameter compatibility?~%~%")

(format t "Expected behavior:~%")
(format t "- Might choose lowpass_filter (has low_freq parameter)~%")
(format t "- Might choose highpass_filter (has high_freq parameter)~%")
(format t "- Should fail gracefully if no parameter match~%~%")

;; Attempt planning
(format t "Starting planning...~%")

(handler-case
  (let ((plan (find-plans 'ecg-5-step-no-bandpass-problem :verbose 1)))
    (if plan
        (progn
          (format t "~%✅ SUCCESS! Domain adapted to missing block:~%~%")
          (let ((actions (first plan))
                (counter 1)
                (step1-block nil))
            (dolist (action actions)
              (when (not (numberp action))
                (format t "~2D. ~A~%" counter action)
                ;; Capture what block was chosen for step1
                (when (and (listp action) 
                          (eq (first action) '!SELECT-BLOCK)
                          (eq (second action) 'STEP1))
                  (setf step1-block (third action)))
                (incf counter)))
            (format t "~%📊 Analysis:~%")
            (format t "- Step1 chose: ~A (instead of bandpass_filter)~%" step1-block)
            (format t "- Domain successfully adapted to constraint~%")
            (format t "- Proves robustness when preferred option unavailable~%")))
        (format t "~%❌ FAILED: Could not find alternative denoising block~%"))
    (format t "~%This test reveals domain's constraint handling strategy~%"))
  (error (e)
    (format t "~%❌ Planning error: ~A~%" e)))

(format t "~%=== No-Bandpass Test Complete ===~%") 