;; ecg_arrhythmia_classification.pddl - ECG arrhythmia classification with comprehensive feature extraction
(define (problem ecg_arrhythmia_classification)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    ts - timeseries
    seg - segments
    feat - features
    sc - scalar
    
    ;; Block instances
    butterworth_filter_05_45hz - block
    enhanced_pan_tompkins - block
    beat_normalizer - block
    morphological_extractor - block
    interval_extractor - block
    spectral_extractor - block
    wavelet_extractor - block
    rfe_feature_selector - block
    ensemble_arrhythmia_classifier - block
    simple_bandpass - block
    threshold_detector - block
    hrv_extractor - block
    quality_assessor - block
    simple_averaging - block
    af_detector - block
    
    ;; Block types
    filter_type - filter
    segmenter_type - segmenter
    extractor_type - extractor
    aggregator_type - aggregator
    
    ;; Pipeline slots
    slot1 slot2 slot3 slot4 slot5 slot6 slot7 slot8 slot9 - pipeline-slot
    
    ;; Purposes
    beat-detection beat-normalization ensemble-classification feature-selection interval-features morphological-features signal-filtering spectral-features wavelet-features - object
  )

  ;; === INITIAL STATE ===
  (:init
    ;; Mark which slots are part of this pipeline
    (pipeline-slot slot1)
    (pipeline-slot slot2)
    (pipeline-slot slot3)
    (pipeline-slot slot4)
    (pipeline-slot slot5)
    (pipeline-slot slot6)
    (pipeline-slot slot7)
    (pipeline-slot slot8)
    (pipeline-slot slot9)

    ;; Pipeline connections
    (slot-connected slot1 slot2)
    (slot-connected slot2 slot3)
    (slot-connected slot3 slot4)
    (slot-connected slot4 slot5)
    (slot-connected slot5 slot6)
    (slot-connected slot6 slot7)
    (slot-connected slot7 slot8)
    (slot-connected slot8 slot9)

    ;; Next-slot relationships
    (next-slot slot1 slot2)
    (next-slot slot2 slot3)
    (next-slot slot3 slot4)
    (next-slot slot4 slot5)
    (next-slot slot5 slot6)
    (next-slot slot6 slot7)
    (next-slot slot7 slot8)
    (next-slot slot8 slot9)

    ;; Data flow requirements for each slot
    (slot-requires-input slot1 ts)
    (slot-requires-output slot1 ts)
    (slot-purpose slot1 signal-filtering)

    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 seg)
    (slot-purpose slot2 beat-detection)

    (slot-requires-input slot3 seg)
    (slot-requires-output slot3 feat)
    (slot-purpose slot3 beat-normalization)

    (slot-requires-input slot4 feat)
    (slot-requires-output slot4 feat)
    (slot-purpose slot4 morphological-features)

    (slot-requires-input slot5 feat)
    (slot-requires-output slot5 feat)
    (slot-purpose slot5 interval-features)

    (slot-requires-input slot6 feat)
    (slot-requires-output slot6 feat)
    (slot-purpose slot6 spectral-features)

    (slot-requires-input slot7 feat)
    (slot-requires-output slot7 feat)
    (slot-purpose slot7 wavelet-features)

    (slot-requires-input slot8 feat)
    (slot-requires-output slot8 feat)
    (slot-purpose slot8 feature-selection)

    (slot-requires-input slot9 feat)
    (slot-requires-output slot9 sc)
    (slot-purpose slot9 ensemble-classification)

    ;; === AVAILABLE BLOCKS ===

    ;; butterworth_filter_05_45hz: Butterworth filter 0.5-45 Hz
    (block-type butterworth_filter_05_45hz filter_type)
    (available butterworth_filter_05_45hz)
    (purpose-match butterworth_filter_05_45hz signal-filtering)
    (valid-parameter-values butterworth_filter_05_45hz)

    ;; enhanced_pan_tompkins: Enhanced Pan-Tompkins algorithm
    (block-type enhanced_pan_tompkins segmenter_type)
    (available enhanced_pan_tompkins)
    (purpose-match enhanced_pan_tompkins beat-detection)
    (valid-parameter-values enhanced_pan_tompkins)

    ;; beat_normalizer: Beat alignment and normalization
    (block-type beat_normalizer extractor_type)
    (available beat_normalizer)
    (purpose-match beat_normalizer beat-normalization)
    (valid-parameter-values beat_normalizer)

    ;; morphological_extractor: P-QRS-T morphological features
    (block-type morphological_extractor extractor_type)
    (available morphological_extractor)
    (purpose-match morphological_extractor morphological-features)
    (valid-parameter-values morphological_extractor)

    ;; interval_extractor: PR, QT, ST interval features
    (block-type interval_extractor extractor_type)
    (available interval_extractor)
    (purpose-match interval_extractor interval-features)
    (valid-parameter-values interval_extractor)

    ;; spectral_extractor: FFT spectral features
    (block-type spectral_extractor extractor_type)
    (available spectral_extractor)
    (purpose-match spectral_extractor spectral-features)
    (valid-parameter-values spectral_extractor)

    ;; wavelet_extractor: Wavelet coefficient features
    (block-type wavelet_extractor extractor_type)
    (available wavelet_extractor)
    (purpose-match wavelet_extractor wavelet-features)
    (valid-parameter-values wavelet_extractor)

    ;; rfe_feature_selector: RFE feature selection
    (block-type rfe_feature_selector extractor_type)
    (available rfe_feature_selector)
    (purpose-match rfe_feature_selector feature-selection)
    (valid-parameter-values rfe_feature_selector)

    ;; ensemble_arrhythmia_classifier: Ensemble arrhythmia classifier
    (block-type ensemble_arrhythmia_classifier aggregator_type)
    (available ensemble_arrhythmia_classifier)
    (purpose-match ensemble_arrhythmia_classifier ensemble-classification)
    (valid-parameter-values ensemble_arrhythmia_classifier)

    ;; simple_bandpass: Simple bandpass filter
    (block-type simple_bandpass filter_type)
    (available simple_bandpass)
    (valid-parameter-values simple_bandpass)

    ;; threshold_detector: Threshold-based detector
    (block-type threshold_detector segmenter_type)
    (available threshold_detector)
    (valid-parameter-values threshold_detector)

    ;; hrv_extractor: HRV feature extraction
    (block-type hrv_extractor extractor_type)
    (available hrv_extractor)
    (valid-parameter-values hrv_extractor)

    ;; quality_assessor: Signal quality assessment
    (block-type quality_assessor extractor_type)
    (available quality_assessor)
    (valid-parameter-values quality_assessor)

    ;; simple_averaging: Simple averaging
    (block-type simple_averaging aggregator_type)
    (available simple_averaging)
    (valid-parameter-values simple_averaging)

    ;; af_detector: Atrial fibrillation detection
    (block-type af_detector aggregator_type)
    (available af_detector)
    (valid-parameter-values af_detector)

    ;; Block type capabilities
    (input-type filter_type ts)
    (output-type filter_type ts)
    
    (input-type segmenter_type ts)
    (output-type segmenter_type seg)
    
    (input-type extractor_type seg)
    (output-type extractor_type feat)
    
    (input-type aggregator_type feat)
    (output-type aggregator_type sc)

  )

  ;; === GOAL ===
  (:goal (and 
    (pipeline-complete)
    (data-flow-valid)
  ))
)