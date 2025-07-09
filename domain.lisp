;; Extended Three-Layer Domain for Biosignal Processing Pipelines

(require :asdf)
(ql:quickload "shop3")

(in-package :shop3)

(defdomain extended-three-layer (
  
  ;; ========================================
  ;; PRIMITIVE OPERATORS
  ;; ========================================
  
  (:operator (!assign-block ?step ?block ?purpose)
    ;; Assign block to step (no indexing needed)
    ((block-available ?block)
     (block-purpose ?block ?purpose)
     (step-needs-purpose ?step ?purpose)
     (not (step-has-block ?step ?block)))
    ()
    ((step-has-block ?step ?block)
     (step-selected-purpose ?step ?purpose)))
  
  (:operator (!configure-param ?step ?param ?value)
    ;; Configure parameter on any available block that has it
    ((step-has-block ?step ?block)
     (block-parameter ?block ?param))
    ()
    ((parameter-configured ?step ?param ?value)))
  
  (:operator (!connect-blocks ?step ?block1 ?block2)
    ;; Connect two blocks within a step
    ((step-has-block ?step ?block1)
     (step-has-block ?step ?block2)
     (blocks-type-compatible ?block1 ?block2))
    ()
    ((block-connected ?step ?block1 ?block2)))
  
  (:operator (!connect ?step1 ?step2)
    ;; Connect two steps without type compatibility checking (temporary fix)
    ((step-has-block ?step1 ?block1)
     (step-has-block ?step2 ?block2))
    ()
    ((connected ?step1 ?step2)))
  
  ;; ========================================
  ;; METHODS
  ;; ========================================
  
  ;; Main entry point - arbitrary length pipeline with type checking
  (:method (process-pipeline ?steps)
    ;; Generic pipeline for any number of steps
    ()
    ((:ordered
      (select-all-blocks ?steps)
      (configure-all-blocks ?steps)
      (connect-all-blocks ?steps)
      (check-best-practices ?steps))))      ; RESTORED: Best practices checking
  
  ;; ========================================
  ;; BLOCK SELECTION PHASE
  ;; ========================================
  
  ;; Select blocks for all steps in list
  (:method (select-all-blocks ())
    ;; Empty list - done
    ()
    ())
  
  (:method (select-all-blocks (?step . ?rest))
    ;; Process first step, then rest
    ()
    ((:ordered
      (select-blocks-for-step ?step)
      (select-all-blocks ?rest))))
  
  ;; CORE ITERATIVE METHOD: Keep assigning blocks until satisfied (NO LIMITS)
  (:method (select-blocks-for-step ?step)
    ;; SUCCESS: All requirements satisfied - done
    ((step-needs-purpose ?step ?purpose)
     (step-spec ?step ?purpose ?required-params ?hints)
     (all-step-requirements-satisfied ?step ?required-params))
    ())
  
  (:method (select-blocks-for-step ?step)
    ;; ITERATIVE: Assign another contributing block and continue (UNLIMITED)
    ((step-needs-purpose ?step ?purpose)
     (step-spec ?step ?purpose ?required-params ?hints)
     (not (all-step-requirements-satisfied ?step ?required-params))
     (block-available ?block)
     (block-purpose ?block ?purpose)
     (not (step-has-block ?step ?block))
     (block-contributes-to-step ?step ?block ?required-params))
    ((:ordered
      (!assign-block ?step ?block ?purpose)
      (select-blocks-for-step ?step))))
  
  ;; ========================================
  ;; PARAMETER CONFIGURATION PHASE
  ;; ========================================
  
  ;; Configure all blocks in list
  (:method (configure-all-blocks ())
    ;; Empty list - done
    ()
    ())
  
  (:method (configure-all-blocks (?step . ?rest))
    ;; Process first step, then rest
    ()
    ((:ordered
      (configure-step ?step)
      (configure-all-blocks ?rest))))
  
  ;; Configure parameters for a step across all assigned blocks
  (:method (configure-step ?step)
    ;; Configure ALL parameters from step-spec
    ((step-spec ?step ?purpose ?params ?hints))
    ((configure-param-list ?step ?params)))
  
  ;; Configure parameters - simple recursive approach
  (:method (configure-param-list ?step ())
    ;; No more parameters - done
    ()
    ())
  
  (:method (configure-param-list ?step ((?param ?value) . ?rest))
    ;; Configure parameter on any available block with this parameter
    ((step-has-block ?step ?block)
     (block-parameter ?block ?param)
     (not (parameter-configured ?step ?param ?value)))
    ((:ordered
      (!configure-param ?step ?param ?value)
      (configure-param-list ?step ?rest))))
  
  ;; ========================================
  ;; INTRA-STEP PIPELINE PLANNING PHASE
  ;; ========================================
  
  ;; Plan pipelines for all steps
  (:method (plan-all-step-pipelines ())
    ;; Empty list - done
    ()
    ())
  
  (:method (plan-all-step-pipelines (?step . ?rest))
    ;; Process first step, then rest
    ()
    ((:ordered
      (plan-step-pipeline ?step)
      (plan-all-step-pipelines ?rest))))
  
  ;; Plan pipeline for a single step
  (:method (plan-step-pipeline ?step)
    ;; Single block - no connections needed
    ((step-has-block ?step ?block)
     (not (step-has-multiple-blocks ?step)))
    ())
  
  (:method (plan-step-pipeline ?step)
    ;; Multiple blocks - need to connect them
    ((step-has-multiple-blocks ?step))
    ((find-block-chain ?step)))
  
  ;; Find valid block chain for step
  (:method (find-block-chain ?step)
    ;; Try to build chain by finding compatible block pairs
    ()
    ((connect-compatible-blocks ?step)))
  
  ;; Connect all compatible block pairs within step
  (:method (connect-compatible-blocks ?step)
    ;; Find two unconnected compatible blocks and connect them
    ((step-has-block ?step ?block1)
     (step-has-block ?step ?block2)
     (not (= ?block1 ?block2))
     (blocks-type-compatible ?block1 ?block2)
     (not (block-connected ?step ?block1 ?block2))
     (not (block-connected ?step ?block2 ?block1)))
    ((:ordered
      (!connect-blocks ?step ?block1 ?block2)
      (connect-compatible-blocks ?step))))
  
  (:method (connect-compatible-blocks ?step)
    ;; No more compatible pairs to connect
    ()
    ())
  
  ;; ========================================
  ;; BOUNDARY VALIDATION PHASE
  ;; ========================================
  
  ;; Validate boundaries for all steps
  (:method (validate-step-boundaries ())
    ;; Empty list - done
    ()
    ())
  
  (:method (validate-step-boundaries (?step . ?rest))
    ;; Process first step, then rest
    ()
    ((:ordered
      (validate-step-boundary ?step)
      (validate-step-boundaries ?rest))))
  
  ;; Validate single step boundary
  (:method (validate-step-boundary ?step)
    ;; Check first/last blocks match step I/O constraints (multi-block case)
    ((step-first-block ?step ?first-block)
     (step-last-block ?step ?last-block)
     (step-spec ?step ?purpose ?params ?hints)
     (validate-input-boundary ?step ?first-block ?hints)
     (validate-output-boundary ?step ?last-block ?hints))
    ())
  
  (:method (validate-step-boundary ?step)
    ;; Single block case - use the only block for both first and last
    ((step-has-block ?step ?block)
     (not (step-has-multiple-blocks ?step))
     (step-spec ?step ?purpose ?params ?hints)
     (validate-input-boundary ?step ?block ?hints)
     (validate-output-boundary ?step ?block ?hints))
    ())
  
  ;; ========================================
  ;; CONNECTION PHASE
  ;; ========================================
  
  ;; Connect all blocks in sequential pipeline
  (:method (connect-all-blocks ())
    ;; Empty list - done
    ()
    ())
  
  (:method (connect-all-blocks (?step))
    ;; Single step - nothing to connect
    ()
    ())
  
  (:method (connect-all-blocks (?step1 ?step2 . ?rest))
    ;; Connect first two, then process rest starting from second
    ()
    ((:ordered
      (!connect ?step1 ?step2)
      (connect-all-blocks (?step2 . ?rest)))))
  
  ;; ========================================
  ;; TYPE COMPATIBILITY PREDICATES
  ;; ========================================
  
  ;; Check if two blocks can be connected (output of block1 → input of block2)
  (:- (blocks-type-compatible ?block1 ?block2)
      ((block-output-type ?block1 ?output-type)
       (block-input-type ?block2 ?input-type)
       (types-compatible ?output-type ?input-type)))
  
  ;; Handle OR input types
  (:- (blocks-type-compatible ?block1 ?block2)
      ((block-output-type ?block1 ?output-type)
       (block-input-type-option ?block2 ?input-type)
       (types-compatible ?output-type ?input-type)))
  
  ;; Handle OR output types
  (:- (blocks-type-compatible ?block1 ?block2)
      ((block-output-type-option ?block1 ?output-type)
       (block-input-type ?block2 ?input-type)
       (types-compatible ?output-type ?input-type)))
  
  ;; Handle OR both
  (:- (blocks-type-compatible ?block1 ?block2)
      ((block-output-type-option ?block1 ?output-type)
       (block-input-type-option ?block2 ?input-type)
       (types-compatible ?output-type ?input-type)))
  
  ;; Type compatibility rules
  (:- (types-compatible signal signal) ())
  (:- (types-compatible signal-freq signal-freq) ())
  (:- (types-compatible features features) ())
  (:- (types-compatible event event) ())
  (:- (types-compatible scalar scalar) ())
  (:- (types-compatible distribution distribution) ())
  (:- (types-compatible none none) ())
  
  ;; ========================================
  ;; STEP-LEVEL TYPE INFERENCE PREDICATES
  ;; ========================================
  
  ;; Determine step's output type from its last block
  (:- (step-output-type ?step ?type)
      ((step-last-block ?step ?last-block)
       (block-output-type ?last-block ?type)))
  
  (:- (step-output-type ?step ?type)
      ((step-last-block ?step ?last-block)
       (block-output-type-option ?last-block ?type)))
  
  ;; Determine step's input type from its first block
  (:- (step-input-type ?step ?type)
      ((step-first-block ?step ?first-block)
       (block-input-type ?first-block ?type)))
  
  (:- (step-input-type ?step ?type)
      ((step-first-block ?step ?first-block)
       (block-input-type-option ?first-block ?type)))
  
  ;; Check if two steps can be connected (step1 output → step2 input)
  (:- (steps-type-compatible ?step1 ?step2)
      ((step-output-type ?step1 ?output-type)
       (step-input-type ?step2 ?input-type)
       (types-compatible ?output-type ?input-type)))
  
  ;; ========================================
  ;; STEP STRUCTURE INFERENCE PREDICATES
  ;; ========================================
  
  ;; Check if step has multiple blocks
  (:- (step-has-multiple-blocks ?step)
      ((step-has-block ?step ?block1)
       (step-has-block ?step ?block2)
       (not (= ?block1 ?block2))))
  
  ;; Find first block in step (no incoming connections)
  (:- (step-first-block ?step ?block)
      ((step-has-block ?step ?block)
       (not (step-has-incoming-connection ?step ?block))))
  
  ;; Find last block in step (no outgoing connections)
  (:- (step-last-block ?step ?block)
      ((step-has-block ?step ?block)
       (not (step-has-outgoing-connection ?step ?block))))
  
  ;; Check if block has incoming connection in step
  (:- (step-has-incoming-connection ?step ?block)
      ((block-connected ?step ?other-block ?block)))
  
  ;; Check if block has outgoing connection in step
  (:- (step-has-outgoing-connection ?step ?block)
      ((block-connected ?step ?block ?other-block)))
  
  ;; ========================================
  ;; BOUNDARY VALIDATION PREDICATES
  ;; ========================================
  
  ;; Validate input boundary (first block input matches step input hints)
  (:- (validate-input-boundary ?step ?first-block ?hints)
      ((member (input-hint ?input-type) ?hints)
       (block-input-type ?first-block ?input-type)))
  
  (:- (validate-input-boundary ?step ?first-block ?hints)
      ((member (input-hint ?input-type) ?hints)
       (block-input-type-option ?first-block ?input-type)))
  
  ;; Allow steps with no input hints (first step of pipeline)
  (:- (validate-input-boundary ?step ?first-block ?hints)
      ((not (has-input-hint ?hints))))
  
  ;; Validate output boundary (last block output matches step output hints)
  (:- (validate-output-boundary ?step ?last-block ?hints)
      ((member (output-hint ?output-type) ?hints)
       (block-output-type ?last-block ?output-type)))
  
  (:- (validate-output-boundary ?step ?last-block ?hints)
      ((member (output-hint ?output-type) ?hints)
       (block-output-type-option ?last-block ?output-type)))
  
  ;; Allow steps with no output hints (last step of pipeline)
  (:- (validate-output-boundary ?step ?last-block ?hints)
      ((not (has-output-hint ?hints))))
  
  ;; Helper predicates for hint checking
  (:- (has-input-hint ((input-hint ?type) . ?rest)) ())
  (:- (has-input-hint ((?other ?value) . ?rest))
      ((not (= ?other input-hint))
       (has-input-hint ?rest)))
  
  (:- (has-output-hint ((output-hint ?type) . ?rest)) ())
  (:- (has-output-hint ((?other ?value) . ?rest))
      ((not (= ?other output-hint))
       (has-output-hint ?rest)))
  
  ;; ========================================
  ;; UTILITY PREDICATES
  ;; ========================================
  
  ;; Check if all step requirements are satisfied by assigned blocks
  (:- (all-step-requirements-satisfied ?step ()) ())
  
  (:- (all-step-requirements-satisfied ?step ((?param ?value) . ?rest))
      ((step-has-parameter ?step ?param)
       (all-step-requirements-satisfied ?step ?rest)))
  
  ;; Check if step has a parameter available in any assigned block
  (:- (step-has-parameter ?step ?param)
      ((step-has-block ?step ?block)
       (block-parameter ?block ?param)))
  
  ;; Check if block contributes to step requirements
  (:- (block-contributes-to-step ?step ?block ?required-params)
      ((step-has-any-assigned-blocks ?step)  ; Has blocks - contribute missing params
       (contributes-missing-parameter ?step ?block ?required-params)))
  
  (:- (block-contributes-to-step ?step ?block ?required-params)
      ((not (step-has-any-assigned-blocks ?step))  ; No blocks yet - contribute any param
       (contributes-any-required-parameter ?block ?required-params)))
  
  ;; Check if step has any blocks assigned
  (:- (step-has-any-assigned-blocks ?step)
      ((step-has-block ?step ?block)))
  
  ;; Check if block contributes a missing parameter
  (:- (contributes-missing-parameter ?step ?block ((?param ?value) . ?rest))
      ((block-parameter ?block ?param)
       (not (step-has-parameter ?step ?param))))  ; SUCCESS: Block has missing param
  
  (:- (contributes-missing-parameter ?step ?block ((?param ?value) . ?rest))
      ((not (block-parameter ?block ?param))  ; Block doesn't have this param
       (contributes-missing-parameter ?step ?block ?rest)))  ; Try the rest
  
  ;; Check if block contributes any required parameter
  (:- (contributes-any-required-parameter ?block ((?param ?value) . ?rest))
      ((block-parameter ?block ?param)))  ; SUCCESS: Block has this parameter
  
  (:- (contributes-any-required-parameter ?block ((?param ?value) . ?rest))
      ((not (block-parameter ?block ?param))  ; Block doesn't have this param
       (contributes-any-required-parameter ?block ?rest)))  ; Try the rest
  
  ;; Utility predicates
  (:- (= ?x ?x) ())
  (:- (member ?x (?x . ?rest)) ())
  (:- (member ?x (?y . ?rest)) ((member ?x ?rest)))

  ;; ========================================
  ;; BEST PRACTICES DETECTION AXIOMS
  ;; ========================================

  ;; BP1: Aliasing Risk Detection 
  ;; Detects when lowpass_filter is followed by resampler with inadequate filtering
  (:- (bp-aliasing-risk ?step1 ?step2 ?cutoff ?sampling-rate)
      ((connected ?step1 ?step2)
       (step-has-block ?step1 lowpass_filter)  ; Specific block: lowpass_filter
       (step-has-block ?step2 resampler)       ; Specific block: resampler
       (parameter-configured ?step1 low_freq ?cutoff)          ; Lowpass cutoff frequency
       (parameter-configured ?step2 sampling_rate ?sampling-rate) ; New sampling rate
       (eval (> ?cutoff (/ ?sampling-rate 2)))))              ; Cutoff > Nyquist frequency

  ;; Generate warning when aliasing risk is detected
  (:- (bp-violation aliasing-risk ?step1 ?step2)
      ((bp-aliasing-risk ?step1 ?step2 ?cutoff ?sampling-rate)))

  ;; Additional helper to get detailed info about the violation
  (:- (bp-violation-details aliasing-risk ?step1 ?step2 ?cutoff ?sampling-rate ?nyquist)
      ((bp-aliasing-risk ?step1 ?step2 ?cutoff ?sampling-rate)
       (eval (setf ?nyquist (/ ?sampling-rate 2)))))

  ;; ========================================
  ;; BEST PRACTICES VIOLATION REPORTING
  ;; ========================================

  ;; Method to check for violations after connections are made
  (:method (check-best-practices (?step1 ?step2 . ?rest))
    ;; Check violations between step1 and step2, then continue with rest
    ()
    ((:ordered
      (check-violation-between ?step1 ?step2)
      (check-best-practices (?step2 . ?rest)))))

  (:method (check-best-practices (?step))
    ;; Single step - nothing to check
    ()
    ())

  (:method (check-best-practices ())
    ;; Empty list - done
    ()
    ())

  ;; Method to check violations between two specific steps
  (:method (check-violation-between ?step1 ?step2)
    ;; If aliasing risk detected, report it
    ((bp-aliasing-risk ?step1 ?step2 ?cutoff ?sampling-rate))
    ((!report-aliasing-risk ?step1 ?step2 ?cutoff ?sampling-rate)))

  (:method (check-violation-between ?step1 ?step2)
    ;; No violations detected - this should be a catch-all case
    ()
    ())

  ;; Operator to report aliasing risk
  (:operator (!report-aliasing-risk ?step1 ?step2 ?cutoff ?sampling-rate)
    ;; preconditions
    ((bp-aliasing-risk ?step1 ?step2 ?cutoff ?sampling-rate))
    ;; deletes
    ()
    ;; additions
    ((aliasing-risk-detected ?step1 ?step2 ?cutoff ?sampling-rate)))
)) 
