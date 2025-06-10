;; ecg_comprehensive_hrv_analysis.pddl - Comprehensive HRV analysis with time, frequency, and non-linear metrics
(define (problem ecg_comprehensive_hrv_analysis)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    ts - timeseries
    seg - segments
    feat - features
    sc - scalar
    
    ;; Block instances
    hrv_preprocessor - block
    pan_tompkins_hrv_detector - block
    ectopic_corrector - block
    nn_interval_calculator - block
    time_domain_analyzer - block
    frequency_domain_analyzer - block
    nonlinear_analyzer - block
    hrv_visualizer - block
    high_frequency_filter - block
    simple_segmenter - block
    morphology_analyzer - block
    compression_analyzer - block
    emotion_classifier - block
    biometric_matcher - block
    
    ;; Block types
    filter_type - filter
    segmenter_type - segmenter
    extractor_type - extractor
    aggregator_type - aggregator
    
    ;; Pipeline slots
    slot1 slot2 slot3 slot4 slot5 slot6 slot7 slot8 - pipeline-slot
    
    ;; Purposes
    artifact-correction frequency-domain-hrv nn-interval-calculation nonlinear-hrv preprocessing result-visualization rpeak-detection time-domain-hrv - object
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
    (slot-purpose slot1 preprocessing)

    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 seg)
    (slot-purpose slot2 rpeak-detection)

    (slot-requires-input slot3 seg)
    (slot-requires-output slot3 feat)
    (slot-purpose slot3 artifact-correction)

    (slot-requires-input slot4 feat)
    (slot-requires-output slot4 feat)
    (slot-purpose slot4 nn-interval-calculation)

    (slot-requires-input slot5 feat)
    (slot-requires-output slot5 feat)
    (slot-purpose slot5 time-domain-hrv)

    (slot-requires-input slot6 feat)
    (slot-requires-output slot6 feat)
    (slot-purpose slot6 frequency-domain-hrv)

    (slot-requires-input slot7 feat)
    (slot-requires-output slot7 feat)
    (slot-purpose slot7 nonlinear-hrv)

    (slot-requires-input slot8 feat)
    (slot-requires-output slot8 sc)
    (slot-purpose slot8 result-visualization)

    ;; === AVAILABLE BLOCKS ===

    ;; hrv_preprocessor: HRV preprocessing (0.5-50 Hz + notch)
    (block-type hrv_preprocessor filter_type)
    (available hrv_preprocessor)
    (purpose-match hrv_preprocessor preprocessing)
    (valid-parameter-values hrv_preprocessor)

    ;; pan_tompkins_hrv_detector: Pan-Tompkins for HRV
    (block-type pan_tompkins_hrv_detector segmenter_type)
    (available pan_tompkins_hrv_detector)
    (purpose-match pan_tompkins_hrv_detector rpeak-detection)
    (valid-parameter-values pan_tompkins_hrv_detector)

    ;; ectopic_corrector: Ectopic beat correction
    (block-type ectopic_corrector extractor_type)
    (available ectopic_corrector)
    (purpose-match ectopic_corrector artifact-correction)
    (valid-parameter-values ectopic_corrector)

    ;; nn_interval_calculator: Normal-to-normal interval calculation
    (block-type nn_interval_calculator extractor_type)
    (available nn_interval_calculator)
    (purpose-match nn_interval_calculator nn-interval-calculation)
    (valid-parameter-values nn_interval_calculator)

    ;; time_domain_analyzer: Time-domain HRV metrics
    (block-type time_domain_analyzer extractor_type)
    (available time_domain_analyzer)
    (purpose-match time_domain_analyzer time-domain-hrv)
    (valid-parameter-values time_domain_analyzer)

    ;; frequency_domain_analyzer: Frequency-domain HRV metrics
    (block-type frequency_domain_analyzer extractor_type)
    (available frequency_domain_analyzer)
    (purpose-match frequency_domain_analyzer frequency-domain-hrv)
    (valid-parameter-values frequency_domain_analyzer)

    ;; nonlinear_analyzer: Non-linear HRV metrics
    (block-type nonlinear_analyzer extractor_type)
    (available nonlinear_analyzer)
    (purpose-match nonlinear_analyzer nonlinear-hrv)
    (valid-parameter-values nonlinear_analyzer)

    ;; hrv_visualizer: HRV result visualization
    (block-type hrv_visualizer aggregator_type)
    (available hrv_visualizer)
    (purpose-match hrv_visualizer result-visualization)
    (valid-parameter-values hrv_visualizer)

    ;; high_frequency_filter: High frequency filter
    (block-type high_frequency_filter filter_type)
    (available high_frequency_filter)
    (valid-parameter-values high_frequency_filter)

    ;; simple_segmenter: Simple segmentation
    (block-type simple_segmenter segmenter_type)
    (available simple_segmenter)
    (valid-parameter-values simple_segmenter)

    ;; morphology_analyzer: Morphological analysis
    (block-type morphology_analyzer extractor_type)
    (available morphology_analyzer)
    (valid-parameter-values morphology_analyzer)

    ;; compression_analyzer: Signal compression
    (block-type compression_analyzer extractor_type)
    (available compression_analyzer)
    (valid-parameter-values compression_analyzer)

    ;; emotion_classifier: Emotion classification
    (block-type emotion_classifier aggregator_type)
    (available emotion_classifier)
    (valid-parameter-values emotion_classifier)

    ;; biometric_matcher: Biometric matching
    (block-type biometric_matcher aggregator_type)
    (available biometric_matcher)
    (valid-parameter-values biometric_matcher)

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