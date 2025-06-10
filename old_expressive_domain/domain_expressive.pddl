;; domain_expressive.pddl - Flexible Biosignal Pipeline Planning Domain
(define (domain biosignal-pipelines)
(:requirements :typing :strips :action-costs :existential-preconditions :derived-predicates)

;; === TYPE HIERARCHY ===
(:types
  datatype block block-type pipeline-slot purpose parameter parameter-type - object
  timeseries segments features scalar event plot file table graph - datatype
  filter segmenter extractor aggregator classifier transformer analyzer detector - block-type
  freq-param time-param threshold-param window-param method-param - parameter-type
  bandpass-param lowpass-param highpass-param notch-param - freq-param
)

;; === PREDICATES ===
(:predicates
  ;; Block-related predicates
  (available ?b - block)
  (has-block-type ?b - block ?t - block-type)
  
  ;; Single input/output type (for backward compatibility)
  (input-type ?t - block-type ?d - datatype)
  (output-type ?t - block-type ?d - datatype)
  
  ;; Multiple input/output types with logic
  (input-type-or ?b - block ?d - datatype)    ; Block accepts any of these input types
  (input-type-and ?b - block ?d - datatype)   ; Block requires all of these input types
  (output-type-or ?b - block ?d - datatype)   ; Block produces any of these output types  
  (output-type-and ?b - block ?d - datatype)  ; Block produces all of these output types
  
  ;; Purpose handling
  (purpose-match ?b - block ?purpose - purpose)
  (block-purpose ?b - block ?purpose - purpose)  ; Multiple purposes per block
  
  ;; Enhanced parameter handling
  (has-parameter ?b - block ?param - parameter)
  (parameter-configured ?b - block ?param - parameter)
  (all-parameters-configured ?b - block)
  (parameter-type ?param - parameter ?ptype - parameter-type)  ; Parameter classification
  (block-uses-parameter-type ?b - block ?ptype - parameter-type)  ; Block requires this parameter type
  (slot-requires-parameter-type ?slot - pipeline-slot ?ptype - parameter-type)  ; Slot requires a block with this parameter type
  
  ;; Pipeline slot predicates
  (slot-requires-input ?slot - pipeline-slot ?d - datatype)
  (slot-requires-output ?slot - pipeline-slot ?d - datatype)
  (slot-purpose ?slot - pipeline-slot ?purpose - purpose)
  (slot-filled ?slot - pipeline-slot ?b - block)
  (slot-connected ?slot1 ?slot2 - pipeline-slot)
  
  ;; Pipeline structure predicates
  (is-pipeline-slot ?slot - pipeline-slot)
  (next-slot ?slot1 ?slot2 - pipeline-slot)
  
  ;; Parameter predicates (backward compatibility)
  (valid-parameter-values ?b - block)
  
  ;; Pipeline state predicates
  (pipeline-complete)
  (data-flow-valid)
  
  ;; Derived predicates
  (input-matches-output ?slot1 ?slot2 - pipeline-slot)
  (all-slots-filled)
  (all-connections-valid)
  (block-input-compatible ?b - block ?slot - pipeline-slot)
  (block-output-compatible ?b - block ?slot - pipeline-slot)
  (block-purpose-compatible ?b - block ?slot - pipeline-slot)
  (block-parameters-compatible ?b - block ?slot - pipeline-slot)
)

;; === DERIVED PREDICATES (AXIOMS) ===

;; Check if block's parameters are compatible with slot requirements
(:derived (block-parameters-compatible ?b - block ?slot - pipeline-slot)
  (forall (?ptype - parameter-type)
    (or
      (not (slot-requires-parameter-type ?slot ?ptype))
      (block-uses-parameter-type ?b ?ptype)
    )
  )
)

;; Check if block input is compatible with slot requirements
(:derived (block-input-compatible ?b - block ?slot - pipeline-slot)
  (or
    ;; Traditional single type compatibility (backward compatibility)
    (exists (?bt - block-type ?dt - datatype)
      (and
        (has-block-type ?b ?bt)
        (input-type ?bt ?dt)
        (slot-requires-input ?slot ?dt)
      )
    )
    ;; OR logic - block accepts any input type that slot provides
    (exists (?dt - datatype)
      (and
        (input-type-or ?b ?dt)
        (slot-requires-input ?slot ?dt)
      )
    )
    ;; AND logic - block requires all input types (would need all slot inputs)
    (forall (?dt - datatype)
      (or
        (not (input-type-and ?b ?dt))
        (slot-requires-input ?slot ?dt)
      )
    )
  )
)

;; Check if block output is compatible with slot requirements  
(:derived (block-output-compatible ?b - block ?slot - pipeline-slot)
  (or
    ;; Traditional single type compatibility (backward compatibility)
    (exists (?bt - block-type ?dt - datatype)
      (and
        (has-block-type ?b ?bt)
        (output-type ?bt ?dt)
        (slot-requires-output ?slot ?dt)
      )
    )
    ;; OR logic - block produces any output type that slot needs
    (exists (?dt - datatype)
      (and
        (output-type-or ?b ?dt)
        (slot-requires-output ?slot ?dt)
      )
    )
    ;; AND logic - block produces all required output types
    (forall (?dt - datatype)
      (or
        (not (slot-requires-output ?slot ?dt))
        (output-type-and ?b ?dt)
      )
    )
  )
)

;; Check if block purpose is compatible with slot
(:derived (block-purpose-compatible ?b - block ?slot - pipeline-slot)
  (or
    ;; Backward compatibility with old purpose-match
    (exists (?purpose - purpose)
      (and
        (slot-purpose ?slot ?purpose)
        (purpose-match ?b ?purpose)
      )
    )
    ;; New multiple purpose support
    (exists (?purpose - purpose)
      (and
        (slot-purpose ?slot ?purpose)
        (block-purpose ?b ?purpose)
      )
    )
  )
)

;; Determine if two connected slots have matching input/output types
(:derived (input-matches-output ?slot1 ?slot2 - pipeline-slot)
  (exists (?dt - datatype)
    (and
      (slot-requires-output ?slot1 ?dt)
      (slot-requires-input ?slot2 ?dt)
      (slot-connected ?slot1 ?slot2)
    )
  )
)

;; Check if all slots in the pipeline are filled
(:derived (all-slots-filled)
  (forall (?slot - pipeline-slot)
    (or
      (not (is-pipeline-slot ?slot))
      (exists (?b - block)
        (slot-filled ?slot ?b)
      )
    )
  )
)

;; Check if all connections in the pipeline have matching data types
(:derived (all-connections-valid)
  (forall (?slot1 ?slot2 - pipeline-slot)
    (or
      (not (and
        (is-pipeline-slot ?slot1)
        (is-pipeline-slot ?slot2)
        (slot-connected ?slot1 ?slot2)
      ))
      (input-matches-output ?slot1 ?slot2)
    )
  )
)

;; === CORE ACTIONS ===

;; Fill a pipeline slot with an appropriate block
(:action fill-slot
  :parameters (?slot - pipeline-slot ?b - block)
  :precondition (and 
    ;; Slot must be part of the pipeline
    (is-pipeline-slot ?slot)
    
    ;; Block must be available
    (available ?b)
    
    ;; Slot must not be filled
    (not (exists (?other-block - block) (slot-filled ?slot ?other-block)))
    
    ;; Type compatibility (using derived predicates)
    (block-input-compatible ?b ?slot)
    (block-output-compatible ?b ?slot)
    
    ;; Purpose compatibility (using derived predicate)
    (block-purpose-compatible ?b ?slot)
    
    ;; Parameter compatibility (new derived predicate)
    (block-parameters-compatible ?b ?slot)
    
    ;; Parameter validation (backward compatibility or new system)
    (or
    (valid-parameter-values ?b)
      (all-parameters-configured ?b)
    )
  )
  :effect (and 
    (slot-filled ?slot ?b)
    (not (available ?b))
  )
)

;; Configure a parameter for a block
(:action configure-parameter
  :parameters (?b - block ?param - parameter)
  :precondition (and
    (available ?b)
    (has-parameter ?b ?param)
    (not (parameter-configured ?b ?param))
  )
  :effect (and
    (parameter-configured ?b ?param)
  )
)

;; Complete the pipeline when all slots are filled and validated
(:action complete-pipeline
  :parameters ()
  :precondition (and 
    (all-slots-filled)
    (all-connections-valid)
  )
  :effect (and 
    (pipeline-complete)
    (data-flow-valid)
  )
)
) 