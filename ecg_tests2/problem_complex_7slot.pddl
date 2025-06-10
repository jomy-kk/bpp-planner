
;; problem.pddl - Dynamic Pipeline Configuration
(define (problem dynamic-biosignal-pipeline)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    feat - feat sc - sc seg - seg ts - ts
    
    ;; Pipeline slots (the "blank steps" to be filled)
    slot1 slot2 slot3 slot4 slot5 slot6 slot7 - pipeline-slot
    
    ;; Available blocks
    preprocess_block - block artifact_block - block segment_block - block freq_block - block time_block - block nonlinear_block - block classify_block - block
    
    ;; Block types
    analyzer_type - analyzer classifier_type - classifier filter_type - filter segmenter_type - segmenter
    
    ;; Purposes
    artifact-removal classification frequency-analysis nonlinear-analysis preprocessing segmentation time-analysis - object
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
    
    ;; Data flow requirements for each slot
    (slot-requires-input slot1 ts)
    (slot-requires-output slot1 ts)
    (slot-purpose slot1 preprocessing)
    
    (slot-requires-input slot2 ts)
    (slot-requires-output slot2 ts)
    (slot-purpose slot2 artifact-removal)
    
    (slot-requires-input slot3 ts)
    (slot-requires-output slot3 seg)
    (slot-purpose slot3 segmentation)
    
    (slot-requires-input slot4 seg)
    (slot-requires-output slot4 feat)
    (slot-purpose slot4 frequency-analysis)
    
    (slot-requires-input slot5 feat)
    (slot-requires-output slot5 feat)
    (slot-purpose slot5 time-analysis)
    
    (slot-requires-input slot6 feat)
    (slot-requires-output slot6 feat)
    (slot-purpose slot6 nonlinear-analysis)
    
    (slot-requires-input slot7 feat)
    (slot-requires-output slot7 sc)
    (slot-purpose slot7 classification)
    
    ;; === AVAILABLE BLOCKS ===
    
    ;; preprocess_block
    (has-block-type preprocess_block filter_type)
    (input-type filter_type ts)
    (output-type filter_type ts)
    (available preprocess_block)
    (purpose-match preprocess_block preprocessing)
    (valid-parameter-values preprocess_block)
    
    ;; artifact_block
    (has-block-type artifact_block filter_type)
    (input-type filter_type ts)
    (output-type filter_type ts)
    (available artifact_block)
    (purpose-match artifact_block artifact-removal)
    (valid-parameter-values artifact_block)
    
    ;; segment_block
    (has-block-type segment_block segmenter_type)
    (input-type segmenter_type ts)
    (output-type segmenter_type seg)
    (available segment_block)
    (purpose-match segment_block segmentation)
    (valid-parameter-values segment_block)
    
    ;; freq_block
    (has-block-type freq_block analyzer_type)
    (input-type analyzer_type seg)
    (output-type analyzer_type feat)
    (available freq_block)
    (purpose-match freq_block frequency-analysis)
    (valid-parameter-values freq_block)
    
    ;; time_block
    (has-block-type time_block analyzer_type)
    (input-type analyzer_type feat)
    (output-type analyzer_type feat)
    (available time_block)
    (purpose-match time_block time-analysis)
    (valid-parameter-values time_block)
    
    ;; nonlinear_block
    (has-block-type nonlinear_block analyzer_type)
    (input-type analyzer_type feat)
    (output-type analyzer_type feat)
    (available nonlinear_block)
    (purpose-match nonlinear_block nonlinear-analysis)
    (valid-parameter-values nonlinear_block)
    
    ;; classify_block
    (has-block-type classify_block classifier_type)
    (input-type classifier_type feat)
    (output-type classifier_type sc)
    (available classify_block)
    (purpose-match classify_block classification)
    (valid-parameter-values classify_block)
    
  )

  ;; === GOAL ===
  (:goal (and 
    (exists (?b - block) (slot-filled slot1 ?b))
    (exists (?b - block) (slot-filled slot2 ?b))
    (exists (?b - block) (slot-filled slot3 ?b))
    (exists (?b - block) (slot-filled slot4 ?b))
    (exists (?b - block) (slot-filled slot5 ?b))
    (exists (?b - block) (slot-filled slot6 ?b))
    (exists (?b - block) (slot-filled slot7 ?b))
  ))
)
