;; ecg_atrial_fibrillation_detection.pddl - ECG atrial fibrillation detection with HRV analysis
(define (problem ecg_atrial_fibrillation_detection)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    ts - timeseries
    seg - segments
    feat - features
    sc - scalar
    
    ;; Block instances
    bandpass_filter_05_50hz - block
    baseline_corrector - block
    wavelet_rpeak_detector - block
    wave_delineator - block
    hrv_feature_extractor - block
    qrst_canceller - block
    spectral_analyzer - block
    random_forest_af_classifier - block
    lowpass_filter - block
    beat_segmenter - block
    morphology_extractor - block
    compression_encoder - block
    svm_classifier - block
    statistical_calculator - block
    
    ;; Block types
    filter_type - filter
    segmenter_type - segmenter
    extractor_type - extractor
    aggregator_type - aggregator
    
    ;; Pipeline slots
    slot1 slot2 slot3 slot4 slot5 slot6 slot7 slot8 - pipeline-slot
    
    ;; Purposes
    af-classification bandpass-filtering baseline-correction hrv-extraction qrst-cancellation rpeak-detection spectral-analysis wave-delineation - object
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

    ;; Pipeline connections
    (slot-connected slot1 slot2)
    (slot-connected slot2 slot3)
    (slot-connected slot3 slot4)
    (slot-connected slot4 slot5)
    (slot-connected slot5 slot6)
    (slot-connected slot6 slot7)
    (slot-connected slot7 slot8)

    ;; Next-slot relationships
    (next-slot slot1 slot2)
    (next-slot slot2 slot3)
    (next-slot slot3 slot4)
    (next-slot slot4 slot5)
    (next-slot slot5 slot6)
    (next-slot slot6 slot7)
    (next-slot slot7 slot8)

    ;; Data flow requirements for each slot
    (slot-requires-input slot1 ts)
    (slot-requires-output slot1 ts)
    (slot-purpose slot1 bandpass-filtering)

    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 ts)
    (slot-purpose slot2 baseline-correction)

    (slot-requires-input slot3 ts)
    (slot-requires-output slot3 seg)
    (slot-purpose slot3 rpeak-detection)

    (slot-requires-input slot4 seg)
    (slot-requires-output slot4 feat)
    (slot-purpose slot4 wave-delineation)

    (slot-requires-input slot5 feat)
    (slot-requires-output slot5 feat)
    (slot-purpose slot5 hrv-extraction)

    (slot-requires-input slot6 feat)
    (slot-requires-output slot6 feat)
    (slot-purpose slot6 qrst-cancellation)

    (slot-requires-input slot7 feat)
    (slot-requires-output slot7 feat)
    (slot-purpose slot7 spectral-analysis)

    (slot-requires-input slot8 feat)
    (slot-requires-output slot8 sc)
    (slot-purpose slot8 af-classification)

    ;; === AVAILABLE BLOCKS ===

    ;; bandpass_filter_05_50hz: Bandpass filter 0.5-50 Hz
    (block-type bandpass_filter_05_50hz filter_type)
    (available bandpass_filter_05_50hz)
    (purpose-match bandpass_filter_05_50hz bandpass-filtering)
    (valid-parameter-values bandpass_filter_05_50hz)

    ;; baseline_corrector: Cubic spline baseline correction
    (block-type baseline_corrector filter_type)
    (available baseline_corrector)
    (purpose-match baseline_corrector baseline-correction)
    (valid-parameter-values baseline_corrector)

    ;; wavelet_rpeak_detector: Wavelet-based R-peak detector
    (block-type wavelet_rpeak_detector segmenter_type)
    (available wavelet_rpeak_detector)
    (purpose-match wavelet_rpeak_detector rpeak-detection)
    (valid-parameter-values wavelet_rpeak_detector)

    ;; wave_delineator: P-wave and T-wave delineation
    (block-type wave_delineator extractor_type)
    (available wave_delineator)
    (purpose-match wave_delineator wave-delineation)
    (valid-parameter-values wave_delineator)

    ;; hrv_feature_extractor: HRV feature extraction
    (block-type hrv_feature_extractor extractor_type)
    (available hrv_feature_extractor)
    (purpose-match hrv_feature_extractor hrv-extraction)
    (valid-parameter-values hrv_feature_extractor)

    ;; qrst_canceller: QRST cancellation with PCA
    (block-type qrst_canceller extractor_type)
    (available qrst_canceller)
    (purpose-match qrst_canceller qrst-cancellation)
    (valid-parameter-values qrst_canceller)

    ;; spectral_analyzer: Spectral analysis 4-9 Hz
    (block-type spectral_analyzer extractor_type)
    (available spectral_analyzer)
    (purpose-match spectral_analyzer spectral-analysis)
    (valid-parameter-values spectral_analyzer)

    ;; random_forest_af_classifier: Random Forest AF classifier
    (block-type random_forest_af_classifier aggregator_type)
    (available random_forest_af_classifier)
    (purpose-match random_forest_af_classifier af-classification)
    (valid-parameter-values random_forest_af_classifier)

    ;; lowpass_filter: Low-pass filter (irrelevant)
    (block-type lowpass_filter filter_type)
    (available lowpass_filter)
    (valid-parameter-values lowpass_filter)

    ;; beat_segmenter: Individual beat segmentation
    (block-type beat_segmenter segmenter_type)
    (available beat_segmenter)
    (valid-parameter-values beat_segmenter)

    ;; morphology_extractor: Morphological feature extraction
    (block-type morphology_extractor extractor_type)
    (available morphology_extractor)
    (valid-parameter-values morphology_extractor)

    ;; compression_encoder: Signal compression
    (block-type compression_encoder extractor_type)
    (available compression_encoder)
    (valid-parameter-values compression_encoder)

    ;; svm_classifier: SVM classifier
    (block-type svm_classifier aggregator_type)
    (available svm_classifier)
    (valid-parameter-values svm_classifier)

    ;; statistical_calculator: Statistical calculator
    (block-type statistical_calculator aggregator_type)
    (available statistical_calculator)
    (valid-parameter-values statistical_calculator)

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