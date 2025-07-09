(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

;; Load domain
(load "domain.lisp")

(defproblem ecg-4-step-validation-problem extended-three-layer
  ;; Initial state with SOLUTION FACTS included
  (
   ;; Available blocks (same as original)
   (block-available lowpass_filter)
   (block-available highpass_filter)
   (block-available bandpass_filter)
   (block-available butterworth_filter)
   (block-available notch_filter)
   (block-available resampler)
   (block-available epoch_segmenter)
   (block-available r_peak_detector)
   (block-available hrv_features_extractor)
   (block-available qrs_features_extractor)
   (block-available morphology_features_extractor)
   (block-available agregate_features)
   (block-available machine_learning_features)

   ;; Block purposes (same as original)
   (block-purpose lowpass_filter denoising)
   (block-purpose highpass_filter denoising)
   (block-purpose bandpass_filter denoising)
   (block-purpose butterworth_filter denoising)
   (block-purpose notch_filter denoising)
   (block-purpose resampler resampling)
   (block-purpose epoch_segmenter segmentation)
   (block-purpose r_peak_detector peak_detection)
   (block-purpose hrv_features_extractor extracting_features)
   (block-purpose qrs_features_extractor extracting_features)
   (block-purpose morphology_features_extractor extracting_features)
   (block-purpose agregate_features arithmetics)
   (block-purpose machine_learning_features machine_learning)

   ;; Block parameters (same as original)
   (block-parameter lowpass_filter low_freq)
   (block-parameter lowpass_filter filter_order)
   (block-parameter highpass_filter high_freq)
   (block-parameter highpass_filter filter_order)
   (block-parameter bandpass_filter low_freq)
   (block-parameter bandpass_filter high_freq)
   (block-parameter bandpass_filter filter_order)
   (block-parameter butterworth_filter cutoff_freq)
   (block-parameter butterworth_filter filter_order)
   (block-parameter notch_filter notch_freq)
   (block-parameter notch_filter q_factor)
   (block-parameter resampler sampling_rate)
   (block-parameter resampler method)
   (block-parameter epoch_segmenter window_size)
   (block-parameter epoch_segmenter window_overlap)
   (block-parameter r_peak_detector threshold)
   (block-parameter r_peak_detector min_distance)
   (block-parameter hrv_features_extractor window_size)
   (block-parameter hrv_features_extractor window_overlap)
   (block-parameter qrs_features_extractor qrs_width)
   (block-parameter qrs_features_extractor feature_types)
   (block-parameter morphology_features_extractor wave_types)
   (block-parameter morphology_features_extractor feature_types)
   (block-parameter agregate_features operation)
   (block-parameter machine_learning_features model_type)
   (block-parameter machine_learning_features feature_count)

   ;; Block I/O types (same as original)
   (block-input-type lowpass_filter signal)
   (block-output-type lowpass_filter signal)
   (block-input-type highpass_filter signal)
   (block-output-type highpass_filter signal)
   (block-input-type bandpass_filter signal)
   (block-output-type bandpass_filter signal)
   (block-input-type butterworth_filter signal)
   (block-output-type butterworth_filter signal)
   (block-input-type notch_filter signal)
   (block-output-type notch_filter signal)
   (block-input-type resampler signal)
   (block-output-type resampler signal)
   (block-input-type epoch_segmenter signal)
   (block-input-type epoch_segmenter event)
   (block-output-type epoch_segmenter signal)
   (block-input-type r_peak_detector signal)
   (block-output-type r_peak_detector event)
   (block-input-type hrv_features_extractor signal)
   (block-output-type hrv_features_extractor features)
   (block-input-type qrs_features_extractor signal)
   (block-output-type qrs_features_extractor features)
   (block-input-type morphology_features_extractor signal)
   (block-output-type morphology_features_extractor features)
   (block-input-type agregate_features features)
   (block-output-type agregate_features scalar)
   (block-input-type machine_learning_features features)
   (block-output-type machine_learning_features features)

   ;; Step specifications (same as original)
   (step-spec step1 denoising 
              ((low_freq 0.5) (high_freq 45.0) (filter_order 4))
              ((input-hint signal) (output-hint signal)))
   (step-spec step2 resampling 
              ((sampling_rate 128) (method linear))
              ((input-hint signal) (output-hint signal)))
   (step-spec step3 extracting_features 
              ((window_size 60) (window_overlap 30))
              ((input-hint signal) (output-hint features)))
   (step-spec step4 arithmetics 
              ((operation mean))
              ((input-hint features) (output-hint scalar)))

   ;; Step goals (same as original)
   (step-needs-purpose step1 denoising)
   (step-needs-purpose step2 resampling)
   (step-needs-purpose step3 extracting_features)
   (step-needs-purpose step4 arithmetics)

   ;; Pipeline structure (same as original)
   (needs-connection step1 step2)
   (needs-connection step2 step3)
   (needs-connection step3 step4)
   
   ;; Pipeline ordering
   (first-step step1)
   (second-step step2)
   (third-step step3)
   (fourth-step step4)

   ;; === SOLUTION FACTS (from successful planning) ===
   ;; Block assignments
   (step-has-block step1 lowpass_filter)
   (step-has-block step1 highpass_filter)
   (step-has-block step2 resampler)
   (step-has-block step3 hrv_features_extractor)
   (step-has-block step4 agregate_features)

   ;; Parameter configurations
   (step-has-parameter step1 low_freq)
   (step-has-parameter step1 high_freq)
   (step-has-parameter step1 filter_order)
   (step-has-parameter step2 sampling_rate)
   (step-has-parameter step2 method)
   (step-has-parameter step3 window_size)
   (step-has-parameter step3 window_overlap)
   (step-has-parameter step4 operation)

   ;; Block connections within steps
   (block-connected step1 lowpass_filter highpass_filter)

   ;; Step connections
   (connected step1 step2)
   (connected step2 step3)
   (connected step3 step4)
  )

  ;; Goal: Process the same 4-step pipeline as the original test
  ;; Since all solution facts are in the initial state, this should be immediately satisfiable
  ((process-pipeline (step1 step2 step3 step4)))
)

;; Validation problem definition completed
;; The actual test will be run by the test file 