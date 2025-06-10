;; 5-Step ECG Processing Problem - NO BANDPASS FILTER
;; Tests domain flexibility when obvious block choice is unavailable

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

;; Load the generic domain
(load "domain_extended.lisp")

(defproblem ecg-5-step-no-bandpass-problem extended-three-layer
  
  ;; ========================================
  ;; BLOCK KNOWLEDGE BASE - ALL Blocks EXCEPT bandpass_filter
  ;; ========================================
  
  ;; ALL blocks from CSV EXCEPT bandpass_filter (21 blocks instead of 22)
  (;; REMOVED: bandpass_filter - the obvious choice for step1
   
   (block-available notch_filter)
   (block-purpose notch_filter denoising)
   (block-purpose notch_filter filter_frequencies)
   (block-parameter notch_filter notch_freq)
   (block-parameter notch_filter quality_factor)
   (block-input-type notch_filter signal)
   (block-output-type notch_filter signal)
   (block-cardinality notch_filter 1 1)
   
   (block-available lowpass_filter)
   (block-purpose lowpass_filter denoising)
   (block-purpose lowpass_filter filter_frequencies)
   (block-parameter lowpass_filter low_freq)
   (block-parameter lowpass_filter filter_order)
   (block-input-type lowpass_filter signal)
   (block-output-type lowpass_filter signal)
   (block-cardinality lowpass_filter 1 1)
   
   (block-available highpass_filter)
   (block-purpose highpass_filter denoising)
   (block-purpose highpass_filter filter_frequencies)
   (block-parameter highpass_filter high_freq)
   (block-parameter highpass_filter filter_order)
   (block-input-type highpass_filter signal)
   (block-output-type highpass_filter signal)
   (block-cardinality highpass_filter 1 1)
   
   (block-available median_filter)
   (block-purpose median_filter denoising)
   (block-purpose median_filter smoothing)
   (block-parameter median_filter window_size)
   (block-parameter median_filter window_overlap)
   (block-input-type median_filter signal)
   (block-output-type median_filter signal)
   (block-cardinality median_filter 1 1)
   
   (block-available emd)
   (block-purpose emd denoising)
   (block-purpose emd extracting_features)
   (block-purpose emd reconstructing_signal)
   (block-parameter emd num_modes)
   (block-parameter emd stopping_criteria)
   (block-input-type emd signal)
   (block-output-type emd signal)
   (block-cardinality emd 1 N)
   
   (block-available r_peak_detector)
   (block-purpose r_peak_detector detecting_temporal_points)
   (block-parameter r_peak_detector window_size)
   (block-parameter r_peak_detector threshold_method)
   (block-input-type r_peak_detector signal)
   (block-output-type r_peak_detector event)
   (block-cardinality r_peak_detector 1 N)
   
   (block-available p_wave_detector)
   (block-purpose p_wave_detector detecting_temporal_points)
   (block-parameter p_wave_detector window_size)
   (block-parameter p_wave_detector threshold_method)
   (block-input-type p_wave_detector signal)
   (block-output-type p_wave_detector event)
   (block-cardinality p_wave_detector 1 N)
   
   (block-available segmenter)
   (block-purpose segmenter segmenting)
   (block-parameter segmenter window_size)
   (block-parameter segmenter window_overlap)
   (block-input-type segmenter signal)
   (block-output-type segmenter signal)
   (block-cardinality segmenter 1 N)
   
   (block-available epoch_segmenter)
   (block-purpose epoch_segmenter segmenting)
   (block-parameter epoch_segmenter window_size)
   (block-parameter epoch_segmenter window_overlap)
   (block-input-type epoch_segmenter signal)
   (block-input-type epoch_segmenter event)
   (block-output-type epoch_segmenter signal)
   (block-cardinality epoch_segmenter 1+E N)
   
   (block-available hrv_features_extractor)
   (block-purpose hrv_features_extractor extracting_features)
   (block-parameter hrv_features_extractor window_size)
   (block-parameter hrv_features_extractor window_overlap)
   (block-input-type hrv_features_extractor signal)
   (block-output-type hrv_features_extractor features)
   (block-cardinality hrv_features_extractor 1 N)
   
   (block-available fft)
   (block-purpose fft transforming_frequency_domain)
   (block-parameter fft method)
   (block-parameter fft low_freq)
   (block-parameter fft high_freq)
   (block-parameter fft window_size)
   (block-parameter fft window_overlap)
   (block-input-type fft signal)
   (block-output-type fft signal-freq)
   (block-cardinality fft 1 1)
   
   (block-available extracting_psd)
   (block-purpose extracting_psd extracting_features)
   (block-parameter extracting_psd low_freq)
   (block-parameter extracting_psd high_freq)
   (block-input-type extracting_psd signal-freq)
   (block-output-type extracting_psd distribution)
   (block-cardinality extracting_psd 1 1)
   
   (block-available pca)
   (block-purpose pca reconstructing_signal)
   (block-purpose pca reduce_dimensionality)
   (block-parameter pca num_components)
   (block-parameter pca variance_retained)
   (block-input-type-option pca features)
   (block-input-type-option pca signal)
   (block-output-type-option pca features)
   (block-output-type-option pca signal)
   (block-cardinality pca N M)
   
   (block-available resampler)
   (block-purpose resampler resampling)
   (block-parameter resampler sampling_rate)
   (block-parameter resampler method)
   (block-input-type resampler signal)
   (block-output-type resampler signal)
   (block-cardinality resampler 1 1)
   
   (block-available normalizer)
   (block-purpose normalizer normalizing)
   (block-parameter normalizer min)
   (block-parameter normalizer max)
   (block-input-type-option normalizer features)
   (block-input-type-option normalizer signal)
   (block-input-type-option normalizer signal-freq)
   (block-output-type-option normalizer features)
   (block-output-type-option normalizer signal)
   (block-output-type-option normalizer signal-freq)
   (block-cardinality normalizer N N)
   
   (block-available generic_features_extractor)
   (block-purpose generic_features_extractor extracting_features)
   (block-input-type generic_features_extractor signal)
   (block-output-type generic_features_extractor features)
   (block-cardinality generic_features_extractor 1 N)
   
   (block-available generic_features_selector)
   (block-purpose generic_features_selector selecting_features)
   (block-purpose generic_features_selector reduce_dimensionality)
   (block-input-type generic_features_selector features)
   (block-output-type generic_features_selector features)
   (block-cardinality generic_features_selector N M)
   
   (block-available agregate_features)
   (block-purpose agregate_features arithmetics)
   (block-purpose agregate_features grouping)
   (block-parameter agregate_features operation)
   (block-input-type agregate_features features)
   (block-output-type agregate_features scalar)
   (block-cardinality agregate_features N 1)
   
   (block-available svm_classifier)
   (block-purpose svm_classifier classification)
   (block-purpose svm_classifier training_ml)
   (block-purpose svm_classifier predicting_ml)
   (block-parameter svm_classifier num_trees)
   (block-parameter svm_classifier max_depth)
   (block-parameter svm_classifier kernel)
   (block-input-type svm_classifier features)
   (block-output-type-option svm_classifier none)
   (block-output-type-option svm_classifier scalar)
   (block-cardinality svm_classifier N 0)
   (block-cardinality svm_classifier N 1)
   
   (block-available svm_regressor)
   (block-purpose svm_regressor regression)
   (block-purpose svm_regressor training_ml)
   (block-purpose svm_regressor predicting_ml)
   (block-parameter svm_regressor num_trees)
   (block-parameter svm_regressor max_depth)
   (block-parameter svm_regressor kernel)
   (block-input-type svm_regressor features)
   (block-output-type-option svm_regressor none)
   (block-output-type-option svm_regressor scalar)
   (block-cardinality svm_regressor N 0)
   (block-cardinality svm_regressor N 1)
   
   ;; ========================================
   ;; STEP SPECIFICATIONS - IDENTICAL to original 5-step
   ;; ========================================
   
   ;; Step 1: SAME AS BEFORE - Denoise with bandpass filter 0.5-45 Hz
   ;; BUT bandpass_filter is NOT AVAILABLE!
   (step-spec step1 denoising 
     ((low_freq 0.5) (high_freq 45.0) (filter_order 4))
     ((output-hint signal)))
   (step-needs-purpose step1 denoising)
   
   ;; Step 2: Resample to 128 Hz
   (step-spec step2 resampling
     ((sampling_rate 128) (method linear))
     ((input-hint signal) (output-hint signal)))
   (step-needs-purpose step2 resampling)
   
   ;; Step 3: Detect R-peaks
   (step-spec step3 detecting_temporal_points
     ((window_size 0.1) (threshold_method adaptive))
     ((input-hint signal) (output-hint event)))
   (step-needs-purpose step3 detecting_temporal_points)
   
   ;; Step 4: Extract HRV features
   (step-spec step4 extracting_features
     ((window_size 60) (window_overlap 30))
     ((input-hint signal) (output-hint features)))
   (step-needs-purpose step4 extracting_features)
   
   ;; Step 5: Aggregate to single value
   (step-spec step5 arithmetics
     ((operation mean))
     ((input-hint features) (output-hint scalar)))
   (step-needs-purpose step5 arithmetics))
  
  ;; ========================================
  ;; GOAL: SAME 5-STEP PIPELINE
  ;; ========================================
  
  ;; Test: What happens when preferred block is unavailable?
  ((process-pipeline (step1 step2 step3 step4 step5)))) 