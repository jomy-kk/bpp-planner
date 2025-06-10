(define (problem ecg_processing_pipeline)
  (:domain htn_biosignal_processing)
  
  (:objects
    ; Data objects
    initial-signal processed-signal-1 processed-signal-2 - signal
    r-peaks - event
    epoched-segments normalized-segments - signal
    freq-domain-signal - signal-freq
    extracted-features - features
    classified-result - scalar
    feature-distribution - distribution
    
    ; Available blocks (from CSV)
    bandpass_filter notch_filter lowpass_filter highpass_filter median_filter - block
    emd r_peak_detector p_wave_detector segmenter epoch_segmenter - block
    hrv_features_extractor fft extracting_psd pca resampler normalizer - block
    generic_features_extractor generic_features_selector agregate_features - block
    svm_classifier svm_regressor - block
    
    ; Purposes
    denoising filter_frequencies extracting_features reconstructing_signal - purpose
    detecting_temporal_points segmenting transforming_frequency_domain - purpose
    reduce_dimensionality resampling normalizing arithmetics grouping - purpose
    classification training_ml predicting_ml regression selecting_features - purpose
    smoothing - purpose
    
    ; Processing slots
    slot1 slot2 slot3 slot4 slot5 - object
    
    ; Input/output ratios
    one many two-plus-events - object
    
    ; Parameters
    low_freq high_freq filter_order notch_freq quality_factor - parameter
    window_size window_overlap threshold_method num_modes stopping_criteria - parameter
    sampling_rate method min max num_components variance_retained - parameter
    operation num_trees max_depth kernel - parameter
  )
  
  (:init
    ; Initial data
    (has-data initial-signal slot1)
    (data-type initial-signal signal)
    
    ; Block availability and properties from CSV
    (block-available bandpass_filter)
    (block-purpose bandpass_filter denoising)
    (block-purpose bandpass_filter filter_frequencies)
    (block-input-type bandpass_filter signal)
    (block-output-type bandpass_filter signal)
    (block-input-output-ratio bandpass_filter one one)
    (block-parameter bandpass_filter low_freq)
    (block-parameter bandpass_filter high_freq)
    (block-parameter bandpass_filter filter_order)
    
    (block-available notch_filter)
    (block-purpose notch_filter denoising)
    (block-purpose notch_filter filter_frequencies)
    (block-input-type notch_filter signal)
    (block-output-type notch_filter signal)
    (block-input-output-ratio notch_filter one one)
    
    (block-available lowpass_filter)
    (block-purpose lowpass_filter denoising)
    (block-purpose lowpass_filter filter_frequencies)
    (block-input-type lowpass_filter signal)
    (block-output-type lowpass_filter signal)
    (block-input-output-ratio lowpass_filter one one)
    
    (block-available highpass_filter)
    (block-purpose highpass_filter denoising)
    (block-purpose highpass_filter filter_frequencies)
    (block-input-type highpass_filter signal)
    (block-output-type highpass_filter signal)
    (block-input-output-ratio highpass_filter one one)
    
    (block-available median_filter)
    (block-purpose median_filter denoising)
    (block-purpose median_filter smoothing)
    (block-input-type median_filter signal)
    (block-output-type median_filter signal)
    (block-input-output-ratio median_filter one one)
    
    (block-available emd)
    (block-purpose emd denoising)
    (block-purpose emd extracting_features)
    (block-purpose emd reconstructing_signal)
    (block-input-type emd signal)
    (block-output-type emd signal)
    (block-input-output-ratio emd one many)
    
    (block-available r_peak_detector)
    (block-purpose r_peak_detector detecting_temporal_points)
    (block-input-type r_peak_detector signal)
    (block-output-type r_peak_detector event)
    (block-input-output-ratio r_peak_detector one many)
    
    (block-available p_wave_detector)
    (block-purpose p_wave_detector detecting_temporal_points)
    (block-input-type p_wave_detector signal)
    (block-output-type p_wave_detector event)
    (block-input-output-ratio p_wave_detector one many)
    
    (block-available segmenter)
    (block-purpose segmenter segmenting)
    (block-input-type segmenter signal)
    (block-output-type segmenter signal)
    (block-input-output-ratio segmenter one many)
    
    (block-available epoch_segmenter)
    (block-purpose epoch_segmenter segmenting)
    (block-input-type epoch_segmenter signal) ; Actually AND(signal event) but simplified
    (block-output-type epoch_segmenter signal)
    (block-input-output-ratio epoch_segmenter two-plus-events many)
    (slot-needs-multiple-inputs slot4) ; epoch_segmenter needs both signal and events
    
    (block-available hrv_features_extractor)
    (block-purpose hrv_features_extractor extracting_features)
    (block-input-type hrv_features_extractor signal)
    (block-output-type hrv_features_extractor features)
    (block-input-output-ratio hrv_features_extractor one many)
    
    (block-available fft)
    (block-purpose fft transforming_frequency_domain)
    (block-input-type fft signal)
    (block-output-type fft signal-freq)
    (block-input-output-ratio fft one one)
    
    (block-available extracting_psd)
    (block-purpose extracting_psd extracting_features)
    (block-input-type extracting_psd signal-freq)
    (block-output-type extracting_psd distribution)
    (block-input-output-ratio extracting_psd one one)
    
    (block-available pca)
    (block-purpose pca reconstructing_signal)
    (block-purpose pca reduce_dimensionality)
    (block-input-type pca features)
    (block-output-type pca features)
    (block-input-output-ratio pca many many)
    
    (block-available resampler)
    (block-purpose resampler resampling)
    (block-input-type resampler signal)
    (block-output-type resampler signal)
    (block-input-output-ratio resampler one one)
    (block-parameter resampler sampling_rate)
    (block-parameter resampler method)
    
    (block-available normalizer)
    (block-purpose normalizer normalizing)
    (block-input-type normalizer signal)
    (block-output-type normalizer signal)
    (block-input-output-ratio normalizer many many)
    (block-parameter normalizer min)
    (block-parameter normalizer max)
    
    (block-available generic_features_extractor)
    (block-purpose generic_features_extractor extracting_features)
    (block-input-type generic_features_extractor signal)
    (block-output-type generic_features_extractor features)
    (block-input-output-ratio generic_features_extractor one many)
    
    (block-available generic_features_selector)
    (block-purpose generic_features_selector selecting_features)
    (block-purpose generic_features_selector reduce_dimensionality)
    (block-input-type generic_features_selector features)
    (block-output-type generic_features_selector features)
    (block-input-output-ratio generic_features_selector many many)
    
    (block-available agregate_features)
    (block-purpose agregate_features arithmetics)
    (block-purpose agregate_features grouping)
    (block-input-type agregate_features features)
    (block-output-type agregate_features scalar)
    (block-input-output-ratio agregate_features many one)
    
    (block-available svm_classifier)
    (block-purpose svm_classifier classification)
    (block-purpose svm_classifier training_ml)
    (block-purpose svm_classifier predicting_ml)
    (block-input-type svm_classifier features)
    (block-output-type svm_classifier scalar)
    (block-input-output-ratio svm_classifier many one)
    
    (block-available svm_regressor)
    (block-purpose svm_regressor regression)
    (block-purpose svm_regressor training_ml)
    (block-purpose svm_regressor predicting_ml)
    (block-input-type svm_regressor features)
    (block-output-type svm_regressor scalar)
    (block-input-output-ratio svm_regressor many one)
    
    ; Parameter requirements for the specific pipeline
    (parameter-required slot1 low_freq 0.5)
    (parameter-required slot1 high_freq 45)
    (parameter-required slot2 sampling_rate 128)
    (parameter-required slot5 min 0)
    (parameter-required slot5 max 1)
  )
  
  (:tasks
    ; Main goal: Complete ECG processing pipeline
    (task1 (process-pipeline denoising signal signal))
    (task2 (process-pipeline resampling signal signal))
    (task3 (process-pipeline detecting_temporal_points signal event))
    (task4 (process-pipeline segmenting signal signal))
    (task5 (process-pipeline normalizing signal signal))
  )
  
  (:ordering
    (task1 < task2)
    (task2 < task3)
    (task3 < task4)
    (task4 < task5)
  )
  
) 