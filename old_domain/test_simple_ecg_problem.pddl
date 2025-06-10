;; test_simple_ecg.pddl - Simple 3-slot ECG pipeline for debugging
(define (problem simple-ecg-pipeline)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    ts - timeseries
    seg - segments
    feat - features
    sc - scalar
    
    ;; Block instances
    bandpass_filter - block
    qrs_detector - block
    hr_extractor - block
    
    ;; Distractor blocks
    notch_filter - block
    artifact_remover - block
    
    ;; Block types
    filter_type - filter
    segmenter_type - segmenter
    extractor_type - extractor
    aggregator_type - aggregator
    
    ;; Pipeline slots
    slot1 slot2 slot3 - pipeline-slot
    
    ;; Purposes
    bandpass_filtering qrs_detection hr_extraction notch_filtering artifact_removal - object
  )

  ;; === INITIAL STATE ===
  (:init
    ;; Mark which slots are part of this pipeline
    (is-pipeline-slot slot1)
    (is-pipeline-slot slot2)
    (is-pipeline-slot slot3)

    ;; Pipeline connections
    (slot-connected slot1 slot2)
    (slot-connected slot2 slot3)

    ;; Next-slot relationships
    (next-slot slot1 slot2)
    (next-slot slot2 slot3)

    ;; Data flow requirements for each slot
    (slot-requires-input slot1 ts)
    (slot-requires-output slot1 ts)
    (slot-purpose slot1 bandpass_filtering)

    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 seg)
    (slot-purpose slot2 qrs_detection)

    (slot-requires-input slot3 seg)
    (slot-requires-output slot3 feat)
    (slot-purpose slot3 hr_extraction)

    ;; === AVAILABLE BLOCKS ===

    ;; Relevant blocks
    (has-block-type bandpass_filter filter_type)
    (available bandpass_filter)
    (purpose-match bandpass_filter bandpass_filtering)
    (valid-parameter-values bandpass_filter)

    (has-block-type qrs_detector segmenter_type)
    (available qrs_detector)
    (purpose-match qrs_detector qrs_detection)
    (valid-parameter-values qrs_detector)

    (has-block-type hr_extractor extractor_type)
    (available hr_extractor)
    (purpose-match hr_extractor hr_extraction)
    (valid-parameter-values hr_extractor)

    ;; Distractor blocks
    (has-block-type notch_filter filter_type)
    (available notch_filter)
    (purpose-match notch_filter notch_filtering)
    (valid-parameter-values notch_filter)

    (has-block-type artifact_remover filter_type)
    (available artifact_remover)
    (purpose-match artifact_remover artifact_removal)
    (valid-parameter-values artifact_remover)

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