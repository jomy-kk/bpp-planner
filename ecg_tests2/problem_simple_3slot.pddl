;; problem.pddl - Dynamic Pipeline Configuration  
(define (problem dynamic-biosignal-pipeline)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data type instances
    sc - scalar seg - segments ts - timeseries
    
    ;; Pipeline slots (the "blank steps" to be filled)
    slot1 slot2 slot3 - pipeline-slot
    
    ;; Available blocks
    denoise_block - block power_block - block segment_block - block
    
    ;; Block types
    extractor_type - extractor filter_type - filter segmenter_type - segmenter
    
    ;; Purposes
    noise-filtering power-analysis segmentation - object
  )

  ;; === INITIAL STATE ===
  (:init
    ;; Mark which slots are part of this pipeline
        (pipeline-slot slot1)
    (pipeline-slot slot2)
    (pipeline-slot slot3)
    
    ;; Data flow requirements for each slot
    (slot-requires-input slot1 ts)
    (slot-requires-output slot1 ts)
    (slot-purpose slot1 noise-filtering)
    
    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 seg)
    (slot-purpose slot2 segmentation)
    
    (slot-requires-input slot3 seg)
    (slot-requires-output slot3 sc)
    (slot-purpose slot3 power-analysis)
    
    ;; === AVAILABLE BLOCKS ===
    
    ;; denoise_block
    (has-block-type denoise_block filter_type)
    (input-type filter_type ts)
    (output-type filter_type ts)
    (available denoise_block)
    (purpose-match denoise_block noise-filtering)
    (valid-parameter-values denoise_block)
    
    ;; segment_block
    (has-block-type segment_block segmenter_type)
    (input-type segmenter_type ts)
    (output-type segmenter_type seg)
    (available segment_block)
    (purpose-match segment_block segmentation)
    (valid-parameter-values segment_block)
    
    ;; power_block
    (has-block-type power_block extractor_type)
    (input-type extractor_type seg)
    (output-type extractor_type sc)
    (available power_block)
    (purpose-match power_block power-analysis)
    (valid-parameter-values power_block)
    
  )

  ;; === GOAL ===
  (:goal (and 
    ;; All pipeline slots must be filled with specific blocks
    (slot-filled slot1 denoise_block)
    (slot-filled slot2 segment_block)
    (slot-filled slot3 power_block)
  ))
)
