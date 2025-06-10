#!/usr/bin/env python3
"""
Dynamic PDDL Problem Generator for Biosignal Pipeline Planning

This script demonstrates how to generate PDDL problem files for any pipeline 
configuration, making the planner work with different slot numbers and types.

Usage: python create_dynamic_problem.py
"""

def generate_pipeline_problem(pipeline_config, available_blocks, output_file):
    """
    Generate a PDDL problem file for any pipeline configuration.
    
    Args:
        pipeline_config: List of (input_type, output_type, purpose) tuples
        available_blocks: Dict of block_name: (block_type, purpose, input_type, output_type)
        output_file: Path to write the problem file
    """
    
    # Generate slot names dynamically
    slots = [f"slot{i+1}" for i in range(len(pipeline_config))]
    
    # Map data type abbreviations to full names and types
    datatype_mapping = {
        "ts": ("ts", "timeseries"),
        "seg": ("seg", "segments"), 
        "feat": ("feat", "features"),
        "sc": ("sc", "scalar")
    }
    
    # Extract unique data types used in this pipeline
    used_datatypes = set()
    for input_dt, output_dt, _ in pipeline_config:
        used_datatypes.add(input_dt)
        used_datatypes.add(output_dt)
    
    # Extract unique purposes and block types
    purposes = set(purpose for _, _, purpose in pipeline_config)
    block_types = set(block_info[0] for block_info in available_blocks.values())
    
    problem_content = f"""
;; problem.pddl - Dynamic Pipeline Configuration  
(define (problem dynamic-biosignal-pipeline)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data type instances
    {' '.join(f"{datatype_mapping[dt][0]} - {datatype_mapping[dt][1]}" for dt in sorted(used_datatypes))}
    
    ;; Pipeline slots (the "blank steps" to be filled)
    {' '.join(slots)} - pipeline-slot
    
    ;; Available blocks
    {' '.join(f"{block_name} - block" for block_name in available_blocks.keys())}
    
    ;; Block types
    {' '.join(f"{bt}_type - {bt}" for bt in sorted(block_types))}
    
    ;; Purposes
    {' '.join(sorted(purposes))} - object
  )

  ;; === INITIAL STATE ===
  (:init
    ;; Mark which slots are part of this pipeline
    {chr(10).join(f"    (pipeline-slot {slot})" for slot in slots)}
    
    ;; Data flow requirements for each slot
"""

    # Add slot requirements
    for i, (input_dt, output_dt, purpose) in enumerate(pipeline_config):
        slot = slots[i]
        input_obj = datatype_mapping[input_dt][0]
        output_obj = datatype_mapping[output_dt][0]
        problem_content += f"""    (slot-requires-input {slot} {input_obj})
    (slot-requires-output {slot} {output_obj})
    (slot-purpose {slot} {purpose})
    
"""

    problem_content += "    ;; === AVAILABLE BLOCKS ===\n    \n"
    
    # Add block definitions
    for block_name, (block_type, purpose, input_dt, output_dt) in available_blocks.items():
        input_obj = datatype_mapping[input_dt][0]
        output_obj = datatype_mapping[output_dt][0]
        problem_content += f"""    ;; {block_name}
    (has-block-type {block_name} {block_type}_type)
    (input-type {block_type}_type {input_obj})
    (output-type {block_type}_type {output_obj})
    (available {block_name})
    (purpose-match {block_name} {purpose})
    (valid-parameter-values {block_name})
    
"""
    
    # Generate goal - require all slots to be filled
    goal_conditions = []
    for slot in slots:
        goal_conditions.append(f"    (exists (?b - block) (slot-filled {slot} ?b))")
    
    problem_content += f"""  )

  ;; === GOAL ===
  (:goal (and 
{chr(10).join(goal_conditions)}
  ))
)
"""
    
    with open(output_file, 'w') as f:
        f.write(problem_content)
    
    print(f"Generated problem file: {output_file}")
    print(f"Pipeline has {len(slots)} slots")
    print(f"Available blocks: {len(available_blocks)}")

def main():
    """Example usage with different pipeline configurations."""
    
    # Example 1: Original 5-slot HRV pipeline
    print("=== Example 1: 5-slot HRV Pipeline ===")
    hrv_pipeline = [
        ("ts", "ts", "bandpass-filtering"),      # slot1: filter
        ("ts", "seg", "segmentation"),           # slot2: segment
        ("seg", "feat", "hrv-extraction"),       # slot3: extract HRV
        ("feat", "feat", "hr-isolation"),        # slot4: isolate HR
        ("feat", "sc", "averaging"),             # slot5: average
    ]
    
    hrv_blocks = {
        "bp_filter_block": ("filter", "bandpass-filtering", "ts", "ts"),
        "segmenter_block": ("segmenter", "segmentation", "ts", "seg"),
        "hrv_extractor_block": ("extractor", "hrv-extraction", "seg", "feat"),
        "hr_getter_block": ("aggregator", "hr-isolation", "feat", "feat"),
        "avg_block": ("aggregator", "averaging", "feat", "sc"),
    }
    
    generate_pipeline_problem(hrv_pipeline, hrv_blocks, "problem_hrv_5slot.pddl")
    
    # Example 2: Simple 3-slot pipeline (using only domain block types)
    print("\n=== Example 2: 3-slot Simple Pipeline ===")
    simple_pipeline = [
        ("ts", "ts", "noise-filtering"),         # slot1: denoise
        ("ts", "seg", "segmentation"),           # slot2: segment  
        ("seg", "sc", "power-analysis"),         # slot3: analyze power
    ]
    
    simple_blocks = {
        "denoise_block": ("filter", "noise-filtering", "ts", "ts"),
        "segment_block": ("segmenter", "segmentation", "ts", "seg"),
        "power_block": ("extractor", "power-analysis", "seg", "sc"),  # Changed from analyzer to extractor
    }
    
    generate_pipeline_problem(simple_pipeline, simple_blocks, "problem_simple_3slot.pddl")
    
    print("\n=== Summary ===")
    print("Generated 2 example problem files demonstrating flexibility:")
    print("- problem_hrv_5slot.pddl (original 5-slot configuration)")
    print("- problem_simple_3slot.pddl (simpler 3-slot pipeline)")  
    print("\nBoth can be solved with the same domain.pddl file!")

if __name__ == "__main__":
    main() 