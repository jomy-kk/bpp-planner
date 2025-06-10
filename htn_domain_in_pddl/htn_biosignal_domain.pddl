(define (domain htn_biosignal_processing)
  
  (:requirements :htn :typing :negative-preconditions)
  
  (:types
    signal event features scalar distribution signal-freq - data-object
    block - object
    purpose - object
    parameter - object
  )
  
  (:predicates
    ; Data availability
    (has-data ?obj - data-object ?slot - object)
    (data-type ?obj - data-object ?type - object)
    
    ; Block properties
    (block-available ?b - block)
    (block-purpose ?b - block ?p - purpose)
    (block-input-type ?b - block ?type - object)
    (block-output-type ?b - block ?type - object)
    (block-input-output-ratio ?b - block ?in-ratio ?out-ratio - object)
    (block-parameter ?b - block ?param - parameter)
    
    ; Processing state
    (block-used ?b - block ?slot - object)
    (slot-filled ?slot - object)
    (slot-purpose ?slot - object ?p - purpose)
    (slot-expects-input ?slot - object ?type - object)
    (slot-produces-output ?slot - object ?type - object)
    
    ; Multi-input handling
    (slot-needs-multiple-inputs ?slot - object)
    (slot-input-satisfied ?slot - object ?input-num - object)
    
    ; Parameter specifications
    (parameter-value ?param - parameter ?value - object)
    (parameter-required ?slot - object ?param - parameter ?value - object)
  )
  
  ; Compound tasks for high-level goals
  (:task process-pipeline :parameters (?goal - purpose ?input-type - object ?output-type - object))
  (:task connect-blocks :parameters (?from-slot ?to-slot - object))
  (:task fill-processing-slot :parameters (?slot - object ?purpose - purpose ?input-type ?output-type - object))
  (:task handle-multi-input :parameters (?slot - object))
  
  ; Method 1: Simple sequential processing
  (:method sequential-processing
    :parameters (?goal - purpose ?input-type ?output-type - object ?intermediate-type - object)
    :task (process-pipeline ?goal ?input-type ?output-type)
    :precondition (and
      (not (= ?input-type ?output-type))
    )
    :subtasks (and
      (task1 (fill-processing-slot slot1 ?goal ?input-type ?intermediate-type))
      (task2 (process-pipeline ?goal ?intermediate-type ?output-type))
    )
    :ordering (and
      (task1 < task2)
    )
  )
  
  ; Method 2: Direct processing (single block)
  (:method direct-processing
    :parameters (?goal - purpose ?input-type ?output-type - object)
    :task (process-pipeline ?goal ?input-type ?output-type)
    :subtasks (and
      (task1 (fill-processing-slot slot1 ?goal ?input-type ?output-type))
    )
  )
  
  ; Method 3: Multi-input processing
  (:method multi-input-processing
    :parameters (?goal - purpose ?input-type ?output-type - object)
    :task (process-pipeline ?goal ?input-type ?output-type)
    :precondition (and
      ; This method is for cases where we need multiple inputs
      (slot-needs-multiple-inputs slot1)
    )
    :subtasks (and
      (task1 (handle-multi-input slot1))
      (task2 (fill-processing-slot slot1 ?goal ?input-type ?output-type))
    )
    :ordering (and
      (task1 < task2)
    )
  )
  
  ; Method for handling multiple inputs
  (:method satisfy-multi-inputs
    :parameters (?slot - object ?input1 ?input2 - object)
    :task (handle-multi-input ?slot)
    :precondition (and
      (slot-needs-multiple-inputs ?slot)
      (not (slot-input-satisfied ?slot input1))
      (not (slot-input-satisfied ?slot input2))
    )
    :subtasks (and
      (task1 (connect-blocks source1 ?slot))
      (task2 (connect-blocks source2 ?slot))
    )
  )
  
  ; Method for connecting blocks
  (:method direct-connection
    :parameters (?from-slot ?to-slot - object)
    :task (connect-blocks ?from-slot ?to-slot)
    :subtasks (and
      (task1 (establish-connection ?from-slot ?to-slot))
    )
  )
  
  ; Method for filling a processing slot
  (:method select-appropriate-block
    :parameters (?slot - object ?purpose - purpose ?input-type ?output-type - object ?block - block)
    :task (fill-processing-slot ?slot ?purpose ?input-type ?output-type)
    :precondition (and
      (block-available ?block)
      (block-purpose ?block ?purpose)
      (block-input-type ?block ?input-type)
      (block-output-type ?block ?output-type)
      (not (block-used ?block ?slot))
    )
    :subtasks (and
      (task1 (apply-block ?block ?slot))
    )
  )
  
  ; Primitive actions
  (:action apply-block
    :parameters (?block - block ?slot - object)
    :precondition (and
      (block-available ?block)
      (not (block-used ?block ?slot))
      (not (slot-filled ?slot))
    )
    :effect (and
      (block-used ?block ?slot)
      (slot-filled ?slot)
    )
  )
  
  (:action establish-connection
    :parameters (?from-slot ?to-slot - object)
    :precondition (and
      (slot-filled ?from-slot)
      (not (slot-filled ?to-slot))
    )
    :effect (and
      ; Connection established
      (slot-input-satisfied ?to-slot ?from-slot)
    )
  )
  
  ; Actions for different input/output ratios
  (:action process-1-to-1
    :parameters (?block - block ?input - data-object ?output - data-object ?slot - object)
    :precondition (and
      (block-used ?block ?slot)
      (block-input-output-ratio ?block one one)
      (has-data ?input ?slot)
    )
    :effect (and
      (has-data ?output ?slot)
      (not (has-data ?input ?slot))
    )
  )
  
  (:action process-1-to-N
    :parameters (?block - block ?input - data-object ?slot - object)
    :precondition (and
      (block-used ?block ?slot)
      (block-input-output-ratio ?block one many)
      (has-data ?input ?slot)
    )
    :effect (and
      ; Multiple outputs created (represented abstractly)
      (has-data output-set ?slot)
      (not (has-data ?input ?slot))
    )
  )
  
  (:action process-N-to-N
    :parameters (?block - block ?slot - object)
    :precondition (and
      (block-used ?block ?slot)
      (block-input-output-ratio ?block many many)
      (has-data input-set ?slot)
    )
    :effect (and
      (has-data output-set ?slot)
      (not (has-data input-set ?slot))
    )
  )
  
  (:action process-2-inputs-to-N
    :parameters (?block - block ?input1 ?input2 - data-object ?slot - object)
    :precondition (and
      (block-used ?block ?slot)
      (block-input-output-ratio ?block two-plus-events many)
      (has-data ?input1 ?slot)
      (has-data ?input2 ?slot)
      (slot-input-satisfied ?slot input1)
      (slot-input-satisfied ?slot input2)
    )
    :effect (and
      (has-data output-set ?slot)
      (not (has-data ?input1 ?slot))
      (not (has-data ?input2 ?slot))
    )
  )
) 