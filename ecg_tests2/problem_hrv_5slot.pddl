
;; problem.pddl - Dynamic Pipeline Configuration  
(define (problem dynamic-biosignal-pipeline)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data type instances
    feat - features sc - scalar seg - segments ts - timeseries
    
    ;; Pipeline slots (the "blank steps" to be filled)
    slot1 slot2 slot3 slot4 slot5 - pipeline-slot
    
    ;; Available blocks
    bp_filter_block - block segmenter_block - block hrv_extractor_block - block hr_getter_block - block avg_block - block
    
    ;; Block types
    aggregator_type - aggregator extractor_type - extractor filter_type - filter segmenter_type - segmenter
    
    ;; Purposes
    averaging bandpass-filtering hr-isolation hrv-extraction segmentation - object
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
    (slot-requires-input slot1 ts)
    (slot-requires-output slot1 ts)
    (slot-purpose slot1 bandpass-filtering)
    
    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 seg)
    (slot-purpose slot2 segmentation)
    
    (slot-requires-input slot3 seg)
    (slot-requires-output slot3 feat)
    (slot-purpose slot3 hrv-extraction)
    
    (slot-requires-input slot4 feat)
    (slot-requires-output slot4 feat)
    (slot-purpose slot4 hr-isolation)
    
    (slot-requires-input slot5 feat)
    (slot-requires-output slot5 sc)
    (slot-purpose slot5 averaging)
    
    ;; === AVAILABLE BLOCKS ===
    
    ;; bp_filter_block
    (has-block-type bp_filter_block filter_type)
    (input-type filter_type ts)
    (output-type filter_type ts)
    (available bp_filter_block)
    (purpose-match bp_filter_block bandpass-filtering)
    (valid-parameter-values bp_filter_block)
    
    ;; segmenter_block
    (has-block-type segmenter_block segmenter_type)
    (input-type segmenter_type ts)
    (output-type segmenter_type seg)
    (available segmenter_block)
    (purpose-match segmenter_block segmentation)
    (valid-parameter-values segmenter_block)
    
    ;; hrv_extractor_block
    (has-block-type hrv_extractor_block extractor_type)
    (input-type extractor_type seg)
    (output-type extractor_type feat)
    (available hrv_extractor_block)
    (purpose-match hrv_extractor_block hrv-extraction)
    (valid-parameter-values hrv_extractor_block)
    
    ;; hr_getter_block
    (has-block-type hr_getter_block aggregator_type)
    (input-type aggregator_type feat)
    (output-type aggregator_type feat)
    (available hr_getter_block)
    (purpose-match hr_getter_block hr-isolation)
    (valid-parameter-values hr_getter_block)
    
    ;; avg_block
    (has-block-type avg_block aggregator_type)
    (input-type aggregator_type feat)
    (output-type aggregator_type sc)
    (available avg_block)
    (purpose-match avg_block averaging)
    (valid-parameter-values avg_block)
    
  )

  ;; === GOAL ===
  (:goal (and 
    (exists (?b - block) (slot-filled slot1 ?b))
    (exists (?b - block) (slot-filled slot2 ?b))
    (exists (?b - block) (slot-filled slot3 ?b))
    (exists (?b - block) (slot-filled slot4 ?b))
    (exists (?b - block) (slot-filled slot5 ?b))
  ))
)
