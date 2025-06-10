;; problem.pddl - Simplified Bandpass-HRV Pipeline Example
(define (problem simple-bandpass-hrv-pipeline)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    ts - timeseries
    seg - segments
    feat - features
    sc - scalar
    
    ;; Block instances (available from LLM database lookup)
    bp_filter_block - block
    segmenter_block - block
    hrv_extractor_block - block
    hr_getter_block - block
    avg_block - block
    
    ;; Block types
    filter_type - filter
    segmenter_type - segmenter
    extractor_type - extractor
    aggregator_type - aggregator
    
    ;; Pipeline slots (the "blank steps" to be filled)
    slot1 slot2 slot3 slot4 slot5 - pipeline-slot
    
    ;; Purposes
    bandpass-filtering segmentation hrv-extraction hr-isolation averaging - object
  )

  ;; === INITIAL STATE ===
  (:init
    ;; Mark which slots are part of this pipeline
    (pipeline-slot slot1)
    (pipeline-slot slot2)
    (pipeline-slot slot3)
    (pipeline-slot slot4)
    (pipeline-slot slot5)
    
    ;; Data flow requirements for each slot
    (slot-requires-input slot1 ts)   ;; [Timeseries] >> ?slot1? >> 
    (slot-requires-output slot1 ts)  ;; >> [Timeseries]
    
    (slot-requires-input slot2 ts)   ;; [Timeseries] >> ?slot2? >>
    (slot-requires-output slot2 seg) ;; >> [Segments]
    
    (slot-requires-input slot3 seg)  ;; [Segments] >> ?slot3? >>
    (slot-requires-output slot3 feat);; >> [Features]
    
    (slot-requires-input slot4 feat) ;; [Features] >> ?slot4? >>
    (slot-requires-output slot4 feat);; >> [Features] 
    
    (slot-requires-input slot5 feat) ;; [Features] >> ?slot5? >>
    (slot-requires-output slot5 sc)  ;; >> [Scalar]
    
    ;; Purpose/intent for each slot (from LLM interpretation)
    (slot-purpose slot1 bandpass-filtering)
    (slot-purpose slot2 segmentation)
    (slot-purpose slot3 hrv-extraction)
    (slot-purpose slot4 hr-isolation)
    (slot-purpose slot5 averaging)
    
    ;; === AVAILABLE BLOCKS (from LLM database lookup) ===
    
    ;; Block types and capabilities
    (has-block-type bp_filter_block filter_type)
    (input-type filter_type ts)
    (output-type filter_type ts)
    
    (has-block-type segmenter_block segmenter_type)
    (input-type segmenter_type ts)
    (output-type segmenter_type seg)
    
    (has-block-type hrv_extractor_block extractor_type)
    (input-type extractor_type seg)
    (output-type extractor_type feat)
    
    (has-block-type hr_getter_block aggregator_type)
    (input-type aggregator_type feat)
    (output-type aggregator_type feat)  ;; Note: outputs features, not scalar
    
    (has-block-type avg_block aggregator_type)
    (input-type aggregator_type feat)
    (output-type aggregator_type sc)
    
    ;; Block availability
    (available bp_filter_block)
    (available segmenter_block)
    (available hrv_extractor_block)
    (available hr_getter_block)
    (available avg_block)
    
    ;; Purpose matching (what each block can do)
    (purpose-match bp_filter_block bandpass-filtering)
    (purpose-match segmenter_block segmentation)
    (purpose-match hrv_extractor_block hrv-extraction)
    (purpose-match hr_getter_block hr-isolation)
    (purpose-match avg_block averaging)

    ;; Parameter validation (all blocks have valid parameters)
    (valid-parameter-values bp_filter_block)
    (valid-parameter-values segmenter_block)
    (valid-parameter-values hrv_extractor_block)
    (valid-parameter-values hr_getter_block)
    (valid-parameter-values avg_block)
  )

  ;; === GOAL ===
  (:goal (and 
    ;; All pipeline slots must be filled with specific blocks
    (slot-filled slot1 bp_filter_block)
    (slot-filled slot2 segmenter_block)
    (slot-filled slot3 hrv_extractor_block)
    (slot-filled slot4 hr_getter_block)
    (slot-filled slot5 avg_block)
  ))
)
