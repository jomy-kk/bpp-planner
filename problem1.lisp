;; 3-Step Biosignal Processing Problem
;; Tests generic domain with different pipeline length

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

;; Load domain
(load "domain.lisp")

(defproblem biosignal-3-step-problem extended-three-layer
  
  ;; ========================================
  ;; BLOCK KNOWLEDGE BASE - ALL Available Blocks from CSV
  ;; ========================================
  
  ;; ALL 22 blocks from simpler_biosignal_blocks.csv
  ((block-available bandpass_filter)
   (block-purpose bandpass_filter denoising)
   (block-purpose bandpass_filter filter_frequencies)
   (block-parameter bandpass_filter low_freq)
   (block-parameter bandpass_filter high_freq)
   (block-parameter bandpass_filter filter_order)
   
   (block-available notch_filter)
   (block-purpose notch_filter denoising)
   (block-purpose notch_filter filter_frequencies)
   (block-parameter notch_filter notch_freq)
   (block-parameter notch_filter quality_factor)
   (block-input-type notch_filter signal)
   (block-output-type notch_filter signal)
   
   (block-available lowpass_filter)
   (block-purpose lowpass_filter denoising)
   (block-purpose lowpass_filter filter_frequencies)
   (block-parameter lowpass_filter low_freq)
   (block-parameter lowpass_filter filter_order)
   
   (block-available highpass_filter)
   (block-purpose highpass_filter denoising)
   (block-purpose highpass_filter filter_frequencies)
   (block-parameter highpass_filter high_freq)
   (block-parameter highpass_filter filter_order)
   
   (block-available median_filter)
   (block-purpose median_filter denoising)
   (block-purpose median_filter smoothing)
   (block-parameter median_filter window_size)
   (block-parameter median_filter window_overlap)
   
   (block-available emd)
   (block-purpose emd denoising)
   (block-purpose emd extracting_features)
   (block-purpose emd reconstructing_signal)
   (block-parameter emd num_modes)
   (block-parameter emd stopping_criteria)
   
   (block-available r_peak_detector)
   (block-purpose r_peak_detector detecting_temporal_points)
   (block-parameter r_peak_detector window_size)
   (block-parameter r_peak_detector threshold_method)
   
   (block-available p_wave_detector)
   (block-purpose p_wave_detector detecting_temporal_points)
   (block-parameter p_wave_detector window_size)
   (block-parameter p_wave_detector threshold_method)
   
   (block-available segmenter)
   (block-purpose segmenter segmenting)
   (block-parameter segmenter window_size)
   (block-parameter segmenter window_overlap)
   
   (block-available epoch_segmenter)
   (block-purpose epoch_segmenter segmenting)
   (block-parameter epoch_segmenter window_size)
   (block-parameter epoch_segmenter window_overlap)
   
   (block-available hrv_features_extractor)
   (block-purpose hrv_features_extractor extracting_features)
   (block-parameter hrv_features_extractor window_size)
   (block-parameter hrv_features_extractor window_overlap)
   
   (block-available fft)
   (block-purpose fft transforming_frequency_domain)
   (block-parameter fft method)
   (block-parameter fft low_freq)
   (block-parameter fft high_freq)
   (block-parameter fft window_size)
   (block-parameter fft window_overlap)
   
   (block-available extracting_psd)
   (block-purpose extracting_psd extracting_features)
   (block-parameter extracting_psd low_freq)
   (block-parameter extracting_psd high_freq)
   
   (block-available pca)
   (block-purpose pca reconstructing_signal)
   (block-purpose pca reduce_dimensionality)
   (block-parameter pca num_components)
   (block-parameter pca variance_retained)
   
   (block-available resampler)
   (block-purpose resampler resampling)
   (block-parameter resampler sampling_rate)
   (block-parameter resampler method)
   
   (block-available normalizer)
   (block-purpose normalizer normalizing)
   (block-parameter normalizer min)
   (block-parameter normalizer max)
   (block-input-type-option normalizer signal)
   (block-output-type-option normalizer signal)
   
   (block-available generic_features_extractor)
   (block-purpose generic_features_extractor extracting_features)
   (block-input-type generic_features_extractor signal)
   (block-output-type generic_features_extractor features)
   
   (block-available generic_features_selector)
   (block-purpose generic_features_selector selecting_features)
   (block-purpose generic_features_selector reduce_dimensionality)
   
   (block-available agregate_features)
   (block-purpose agregate_features arithmetics)
   (block-purpose agregate_features grouping)
   (block-parameter agregate_features operation)
   
   (block-available svm_classifier)
   (block-purpose svm_classifier classification)
   (block-purpose svm_classifier training_ml)
   (block-purpose svm_classifier predicting_ml)
   (block-parameter svm_classifier num_trees)
   (block-parameter svm_classifier max_depth)
   (block-parameter svm_classifier kernel)
   
   (block-available svm_regressor)
   (block-purpose svm_regressor regression)
   (block-purpose svm_regressor training_ml)
   (block-purpose svm_regressor predicting_ml)
   (block-parameter svm_regressor num_trees)
   (block-parameter svm_regressor max_depth)
   (block-parameter svm_regressor kernel)
   
   ;; ========================================
   ;; STEP SPECIFICATIONS - 3-Step Pipeline
   ;; ========================================
   
   ;; Step 1: Filter out noise with notch filter (different from 5-step example)
   (step-spec step1 denoising 
     ((notch_freq 50) (quality_factor 30))
     ((output-hint signal)))
   (step-needs-purpose step1 denoising)
   
   ;; Step 2: Normalize signal
   (step-spec step2 normalizing
     ((min 0) (max 1))
     ((input-hint signal) (output-hint signal)))
   (step-needs-purpose step2 normalizing)
   
   ;; Step 3: Extract features 
   (step-spec step3 extracting_features
     ((window_size 1.0) (window_overlap 0.5))
     ((input-hint signal) (output-hint features)))
   (step-needs-purpose step3 extracting_features))
  
  ;; ========================================
  ;; GOAL: 3-STEP PIPELINE (DIFFERENT LENGTH)
  ;; ========================================
  
  ;; Test: Can the SAME domain handle a 3-step pipeline?
  ((process-pipeline (step1 step2 step3)))) 