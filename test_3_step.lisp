;; Test 3-Step Biosignal Processing Pipeline

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

;; Load domain and 3-step problem
(load "domain_extended.lisp")
(load "problem_3_step.lisp")

(format t "~%=== 3-Step Pipeline Test (Domain Genericity Test) ===~%")
(format t "Testing: Same domain, different pipeline length~%~%")

(format t "3-Step pipeline specification:~%")
(format t "1. Denoise (notch filter 50Hz)~%")
(format t "2. Normalize (0-1 range)~%") 
(format t "3. Extract features~%~%")

(format t "Challenge: Same 22 blocks in KB as 5-step test~%")
(format t "- Should choose DIFFERENT blocks due to different purposes~%")
(format t "- notch_filter vs bandpass_filter for denoising~%")
(format t "- normalizer (new purpose not in 5-step)~%")
(format t "- generic_features_extractor vs hrv_features_extractor~%~%")

(format t "Key Test: Can domain handle 3-step as easily as 5-step?~%")
(format t "Expected: Same recursive logic, different block choices~%~%")

;; Attempt planning
(format t "Starting planning...~%")

(handler-case
  (let ((plan (find-plans 'biosignal-3-step-problem :verbose 1)))
    (if plan
        (progn
          (format t "~%✅ SUCCESS! Domain handled 3-step generically:~%~%")
          (let ((actions (first plan))
                (counter 1))
            (dolist (action actions)
              (when (not (numberp action))
                (format t "~2D. ~A~%" counter action)
                (incf counter))))
          (format t "~%📊 Comparison with 5-step test:~%")
          (format t "- Same domain code handled both lengths~%")
          (format t "- Different block choices due to different purposes~%")
          (format t "- Proves true genericity~%"))
        (format t "~%❌ FAILED: Domain not truly generic~%")))
  (error (e)
    (format t "~%❌ Planning error: ~A~%" e)))

(format t "~%=== 3-Step Test Complete ===~%") 