# LAMA Planner with Expressive Biosignal Pipeline Domain

This implementation demonstrates using the LAMA (Landmark-based Meta Agent) planner with an expressive PDDL domain for biosignal processing pipelines. This approach preserves the advanced PDDL features like existential quantifiers and derived predicates, which are essential for flexible pipeline construction.

## Files

- `domain_expressive.pddl`: The expressive domain file that includes:
  - Existential quantifiers
  - Universal quantifiers
  - Derived predicates (axioms)
  - Type hierarchy
  - Complex preconditions and effects

- `problem_expressive.pddl`: The corresponding problem file for a 5-slot bandpass-HRV processing pipeline

- `test_lama_planner.py`: Script to run and test the LAMA planner with the expressive domain

- `lama_planner/`: The LAMA planner implementation (Fast Downward)

## How It Works

Unlike simpler planners like Fast Downward's default configuration, LAMA can handle advanced PDDL features required for:

1. **Dynamic Type Checking**: Using derived predicates to validate connections between pipeline slots
2. **Flexible Goal Definition**: Using existentially quantified goals instead of hard-coded block placement
3. **Expressive Action Preconditions**: Using complex preconditions with nested quantifiers for actions

## Key Features of the Expressive Domain

### Derived Predicates (Axioms)

```pddl
;; Check if all slots in the pipeline are filled
(:derived (all-slots-filled)
  (forall (?slot - pipeline-slot)
    (or
      (not (pipeline-slot ?slot))
      (exists (?b - block)
        (slot-filled ?slot ?b)
      )
    )
  )
)
```

### Existential Quantifiers in Action Preconditions

```pddl
;; Fill a pipeline slot with an appropriate block
(:action fill-slot
  :parameters (?slot - pipeline-slot ?b - block ?bt - block-type)
  :precondition (and 
    ;; Type compatibility
    (exists (?input-dt ?output-dt - datatype)
      (and
        (slot-requires-input ?slot ?input-dt)
        (slot-requires-output ?slot ?output-dt)
        (input-type ?bt ?input-dt)
        (output-type ?bt ?output-dt)
      )
    )
    
    ;; Purpose compatibility
    (exists (?purpose - object)
      (and
        (slot-purpose ?slot ?purpose)
        (purpose-match ?b ?purpose)
      )
    )
    
    ;; Other preconditions...
  )
  :effect (and 
    (slot-filled ?slot ?b)
    (not (available ?b))
  )
)
```

## Running the Planner

To run the planner:

```bash
./test_lama_planner.py
```

This will:
1. Run LAMA on the expressive domain and problem
2. Generate a plan filling all pipeline slots
3. Display the resulting plan

## Benefits of This Approach

1. **More Flexible Planning**: The planner can handle complex constraints and goals
2. **Better Data Flow Validation**: Explicit checks for data type compatibility between slots
3. **Clearer Semantics**: The domain more accurately represents the biosignal pipeline problem
4. **Simplified Goal Definition**: Goals can be specified at a higher level (pipeline complete) rather than listing each exact block placement

## Limitations

1. The LAMA planner is more resource-intensive than simpler planners
2. Plan generation may take longer for very complex problems
3. Not all planning systems support the full range of PDDL features

## Next Steps

- Add more complex constraints like quality metrics and cost functions
- Extend the domain to support branching pipelines
- Integrate with the LLM component for dynamic problem generation 