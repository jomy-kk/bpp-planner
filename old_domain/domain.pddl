;; domain.pddl - Flexible Biosignal Pipeline Planning Domain
(define (domain biosignal-pipelines)
(:requirements :typing :strips)

;; === TYPE HIERARCHY ===
(:types
  datatype block block-type pipeline-slot - object
  timeseries segments features scalar - datatype
  filter segmenter extractor aggregator - block-type
)

;; === PREDICATES ===
(:predicates
  ;; Block-related predicates
  (available ?b - block)
  (has-block-type ?b ?t - block-type)
  (input-type ?t - block-type ?d - datatype)
  (output-type ?t - block-type ?d - datatype)
  (purpose-match ?b - block ?purpose - object)
  
  ;; Pipeline slot predicates
  (slot-requires-input ?slot - pipeline-slot ?d - datatype)
  (slot-requires-output ?slot - pipeline-slot ?d - datatype)
  (slot-purpose ?slot - pipeline-slot ?purpose - object)
  (slot-filled ?slot - pipeline-slot ?b - block)
  
  ;; Pipeline structure predicates
  (pipeline-slot ?slot - pipeline-slot)
  
  ;; Parameter predicates (simplified)
  (valid-parameter-values ?b - block)
)

;; === CORE ACTIONS ===

;; Fill a pipeline slot with an appropriate block
(:action fill-slot
  :parameters (?slot - pipeline-slot ?b - block ?bt - block-type ?input-dt ?output-dt - datatype ?purpose - object)
  :precondition (and 
    ;; Slot must be part of the pipeline
    (pipeline-slot ?slot)
    
    ;; Block must be available and of correct type
    (available ?b)
    (has-block-type ?b ?bt)

    ;; Slot requirements
    (slot-requires-input ?slot ?input-dt)
    (slot-requires-output ?slot ?output-dt)
    (slot-purpose ?slot ?purpose)
    
    ;; Type compatibility
    (input-type ?bt ?input-dt)
    (output-type ?bt ?output-dt)
    
    ;; Purpose compatibility
    (purpose-match ?b ?purpose)
    
    ;; Valid parameters
    (valid-parameter-values ?b)
  )
  :effect (and 
    (slot-filled ?slot ?b)
    (not (available ?b))
  )
)
)