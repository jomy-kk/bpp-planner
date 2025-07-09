(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

(load "domain_extended.lisp")

(defproblem ecg-bad-practice-aliasing extended-three-layer
  ;; Initial state with BAD PRACTICE solution pre-loaded
  (
   ;; Available blocks
   (block-available lowpass_filter)
   (block-available resampler)
   (block-available hrv_features_extractor)
   (block-available agregate_features)

   ;; Block purposes
   (block-purpose lowpass_filter denoising)
   (block-purpose resampler resampling)
   (block-purpose hrv_features_extractor extracting_features)
   (block-purpose agregate_features arithmetics)

   ;; Block parameters
   (block-parameter lowpass_filter low_freq)
   (block-parameter lowpass_filter filter_order)
   (block-parameter resampler sampling_rate)
   (block-parameter resampler method)
   (block-parameter hrv_features_extractor window_size)
   (block-parameter hrv_features_extractor window_overlap)
   (block-parameter agregate_features operation)

   ;; Block I/O types
   (block-input-type lowpass_filter signal)
   (block-output-type lowpass_filter signal)
   (block-input-type resampler signal)
   (block-output-type resampler signal)
   (block-input-type hrv_features_extractor signal)
   (block-output-type hrv_features_extractor features)
   (block-input-type agregate_features features)
   (block-output-type agregate_features scalar)

   ;; Step specifications with BAD PRACTICE parameters
   (step-spec step1 denoising 
              ((low_freq 60) (filter_order 4))  ; Lowpass at 60Hz
              ((output-hint signal)))
   (step-spec step2 resampling 
              ((sampling_rate 100) (method linear))  ; Downsample to 100Hz
              ((input-hint signal) (output-hint signal)))   ; PROBLEM: 60Hz > 50Hz Nyquist!
   (step-spec step3 extracting_features 
              ((window_size 60) (window_overlap 30))
              ((input-hint signal) (output-hint features)))
   (step-spec step4 arithmetics 
              ((operation mean))
              ((input-hint features) (output-hint scalar)))

   ;; Step goals
   (step-needs-purpose step1 denoising)
   (step-needs-purpose step2 resampling)
   (step-needs-purpose step3 extracting_features)
   (step-needs-purpose step4 arithmetics)

   ;; Pipeline structure
   (needs-connection step1 step2)
   (needs-connection step2 step3)
   (needs-connection step3 step4)

   ;; Pipeline ordering
   (first-step step1)
   (second-step step2)
   (third-step step3)
   (fourth-step step4)

   ;; === BAD PRACTICE SOLUTION FACTS ===
   ;; Block assignments
   (step-has-block step1 lowpass_filter)
   (step-has-block step2 resampler)
   (step-has-block step3 hrv_features_extractor)
   (step-has-block step4 agregate_features)

   ;; Parameter configurations - THE BAD PRACTICE
   (step-has-parameter step1 low_freq)      ; 60Hz lowpass
   (step-has-parameter step1 filter_order)
   (step-has-parameter step2 sampling_rate) ; 100Hz downsample
   (step-has-parameter step2 method)
   (step-has-parameter step3 window_size)
   (step-has-parameter step3 window_overlap)
   (step-has-parameter step4 operation)

   ;; Step connections - BAD PRACTICE!
   (connected step1 step2)  ; lowpass_filter (60Hz) → resampler (100Hz)
   (connected step2 step3)  ; This causes aliasing: 60Hz > 50Hz Nyquist!
   (connected step3 step4)
  )

  ;; Goal: Process pipeline (should succeed but with warnings)
  ((process-pipeline (step1 step2 step3 step4)))
)

;; Problem definition completed
;; DEMONSTRATES: Aliasing risk with lowpass 60Hz followed by downsample 100Hz
;; VIOLATION: 60Hz cutoff > 50Hz Nyquist frequency = ALIASING!