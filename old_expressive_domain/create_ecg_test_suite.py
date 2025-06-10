#!/usr/bin/env python3
"""
ECG Pipeline Test Suite Generator

This script creates comprehensive test cases for ECG biosignal pipelines
based on the examples from final_examples ECG.csv. Each test includes:
- Relevant blocks for the specific pipeline
- Irrelevant/distractor blocks to test search capabilities
- Proper data flow and purpose matching
"""

import os
import subprocess
from pathlib import Path
import csv

def create_test_case(test_name, description, slots_config, relevant_blocks, distractor_blocks):
    """Create a PDDL problem file for a specific ECG test case."""
    
    # Count total slots
    num_slots = len(slots_config)
    
    # Create slot names
    slot_names = [f"slot{i+1}" for i in range(num_slots)]
    
    # All available blocks (relevant + distractors)
    all_blocks = {**relevant_blocks, **distractor_blocks}
    
    # Create purposes list from slot configs and distractor purposes
    purposes = list(set(slot['purpose'] for slot in slots_config))
    # Add distractor purposes
    for block_info in distractor_blocks.values():
        if 'purpose' in block_info:
            purposes.append(block_info['purpose'])
    purposes = list(set(purposes))  # Remove duplicates
    
    # Start creating the problem file
    problem_file = f"test_ecg_{test_name}.pddl"
    
    problem_content = f""";; test_ecg_{test_name}.pddl - {description}
(define (problem ecg-{test_name}-pipeline)
  (:domain biosignal-pipelines)

  ;; === OBJECT DECLARATIONS ===
  (:objects
    ;; Data types
    ts - timeseries
    seg - segments
    feat - features
    sc - scalar
    
    ;; Block instances
"""
    
    # Add block instances
    for block_name in all_blocks.keys():
        problem_content += f"    {block_name} - block\n"
    
    problem_content += f"""
    ;; Block types
    filter_type - filter
    segmenter_type - segmenter
    extractor_type - extractor
    aggregator_type - aggregator
    
    ;; Pipeline slots
"""
    
    # Add slot instances
    for slot_name in slot_names:
        problem_content += f"    {slot_name} - pipeline-slot\n"
    
    problem_content += f"""
    ;; Purposes
"""
    
    # Add purpose instances
    for purpose in purposes:
        problem_content += f"    {purpose} - object\n"
    
    problem_content += f"""
  )

  ;; === INITIAL STATE ===
  (:init
    ;; Mark which slots are part of this pipeline
"""
    
    # Add pipeline slots
    for slot_name in slot_names:
        problem_content += f"    (is-pipeline-slot {slot_name})\n"
    
    problem_content += "\n    ;; Pipeline connections\n"
    
    # Add connections between consecutive slots
    for i in range(len(slot_names) - 1):
        problem_content += f"    (slot-connected {slot_names[i]} {slot_names[i+1]})\n"
    
    problem_content += "\n    ;; Next-slot relationships\n"
    for i in range(len(slot_names) - 1):
        problem_content += f"    (next-slot {slot_names[i]} {slot_names[i+1]})\n"
    
    problem_content += "\n    ;; Data flow requirements for each slot\n"
    
    # Add slot requirements
    for i, slot_info in enumerate(slots_config):
        slot_name = slot_names[i]
        problem_content += f"    (slot-requires-input {slot_name} {slot_info['input']})\n"
        problem_content += f"    (slot-requires-output {slot_name} {slot_info['output']})\n"
        problem_content += f"    (slot-purpose {slot_name} {slot_info['purpose']})\n"
        problem_content += "\n"
    
    problem_content += "    ;; === AVAILABLE BLOCKS ===\n\n"
    
    # Add block type definitions and availability
    for block_name, block_info in all_blocks.items():
        problem_content += f"    ;; {block_name}: {block_info.get('description', 'Processing block')}\n"
        problem_content += f"    (has-block-type {block_name} {block_info['type']})\n"
        problem_content += f"    (available {block_name})\n"
        
        # Add purpose matching for ALL blocks (relevant + distractors)
        if 'purpose' in block_info:
            problem_content += f"    (purpose-match {block_name} {block_info['purpose']})\n"
        
        problem_content += f"    (valid-parameter-values {block_name})\n\n"
    
    # Add block type capabilities
    problem_content += """    ;; Block type capabilities
    (input-type filter_type ts)
    (output-type filter_type ts)
    
    (input-type segmenter_type ts)
    (output-type segmenter_type seg)
    
    (input-type extractor_type seg)
    (output-type extractor_type feat)
    
    (input-type aggregator_type feat)
    (output-type aggregator_type sc)
  )

  ;; === GOAL ===
  (:goal (and 
    (pipeline-complete)
    (data-flow-valid)
  ))
)
"""
    
    # Write the problem file
    with open(problem_file, 'w') as f:
        f.write(problem_content)
    
    return problem_file

def analyze_ecg_examples():
    """Analyze the ECG examples CSV file to extract pipeline configurations."""
    
    test_cases = []
    
    # ECG Test Case 1: Arrhythmia Detection Pipeline (Pipeline 1)
    test_cases.append({
        "name": "arrhythmia_detection",
        "description": "ECG Arrhythmia Detection Pipeline with QRS Detection and Beat Classification",
        "slots": [
            {"input": "ts", "output": "ts", "purpose": "bandpass_filtering"},
            {"input": "ts", "output": "ts", "purpose": "notch_filtering"},
            {"input": "ts", "output": "ts", "purpose": "denoising"},
            {"input": "ts", "output": "seg", "purpose": "qrs_detection"},
            {"input": "seg", "output": "feat", "purpose": "peak_identification"},
            {"input": "feat", "output": "feat", "purpose": "heart_rate_calculation"},
            {"input": "feat", "output": "sc", "purpose": "beat_classification"},
        ],
        "relevant_blocks": {
            "bandpass_filter": {"type": "filter_type", "purpose": "bandpass_filtering"},
            "notch_filter": {"type": "filter_type", "purpose": "notch_filtering"},
            "wavelet_denoiser": {"type": "filter_type", "purpose": "denoising"},
            "qrs_detector": {"type": "segmenter_type", "purpose": "qrs_detection"},
            "peak_identifier": {"type": "extractor_type", "purpose": "peak_identification"},
            "hr_calculator": {"type": "extractor_type", "purpose": "heart_rate_calculation"},
            "beat_classifier": {"type": "aggregator_type", "purpose": "beat_classification"},
        },
        "distractors": {
            "baseline_corrector": {"type": "filter_type", "purpose": "baseline_correction"},
            "artifact_remover": {"type": "filter_type", "purpose": "artifact_removal"},
            "fft_analyzer": {"type": "extractor_type", "purpose": "spectral_analysis"},
            "ml_classifier": {"type": "aggregator_type", "purpose": "ml_classification"},
            "visualizer": {"type": "aggregator_type", "purpose": "visualization"},
        }
    })
    
    # ECG Test Case 2: HRV Analysis Pipeline (Pipeline 2)
    test_cases.append({
        "name": "hrv_analysis",
        "description": "ECG Heart Rate Variability Analysis Pipeline",
        "slots": [
            {"input": "ts", "output": "ts", "purpose": "bandpass_filtering"},
            {"input": "ts", "output": "ts", "purpose": "baseline_correction"},
            {"input": "ts", "output": "seg", "purpose": "peak_detection"},
            {"input": "seg", "output": "feat", "purpose": "wave_delineation"},
            {"input": "feat", "output": "feat", "purpose": "hrv_extraction"},
            {"input": "feat", "output": "sc", "purpose": "classification"},
        ],
        "relevant_blocks": {
            "bandpass_filter": {"type": "filter_type", "purpose": "bandpass_filtering"},
            "baseline_corrector": {"type": "filter_type", "purpose": "baseline_correction"},
            "peak_detector": {"type": "segmenter_type", "purpose": "peak_detection"},
            "wave_delineator": {"type": "extractor_type", "purpose": "wave_delineation"},
            "hrv_extractor": {"type": "extractor_type", "purpose": "hrv_extraction"},
            "rf_classifier": {"type": "aggregator_type", "purpose": "classification"},
        },
        "distractors": {
            "notch_filter": {"type": "filter_type", "purpose": "notch_filtering"},
            "wavelet_denoiser": {"type": "filter_type", "purpose": "denoising"},
            "qrs_detector": {"type": "segmenter_type", "purpose": "qrs_detection"},
            "morphology_extractor": {"type": "extractor_type", "purpose": "morphology_extraction"},
            "statistical_aggregator": {"type": "aggregator_type", "purpose": "statistical_analysis"},
            "data_compressor": {"type": "aggregator_type", "purpose": "compression"},
        }
    })
    
    # ECG Test Case 3: Beat Morphology Analysis (Pipeline 5)
    test_cases.append({
        "name": "beat_morphology",
        "description": "ECG Beat Morphology Analysis and Classification Pipeline",
        "slots": [
            {"input": "ts", "output": "ts", "purpose": "filtering"},
            {"input": "ts", "output": "seg", "purpose": "beat_detection"},
            {"input": "seg", "output": "seg", "purpose": "alignment"},
            {"input": "seg", "output": "feat", "purpose": "morphology_extraction"},
            {"input": "feat", "output": "feat", "purpose": "feature_selection"},
            {"input": "feat", "output": "sc", "purpose": "ensemble_classification"},
        ],
        "relevant_blocks": {
            "butterworth_filter": {"type": "filter_type", "purpose": "filtering"},
            "beat_detector": {"type": "segmenter_type", "purpose": "beat_detection"},
            "beat_aligner": {"type": "segmenter_type", "purpose": "alignment"},
            "morphology_extractor": {"type": "extractor_type", "purpose": "morphology_extraction"},
            "feature_selector": {"type": "extractor_type", "purpose": "feature_selection"},
            "ensemble_classifier": {"type": "aggregator_type", "purpose": "ensemble_classification"},
        },
        "distractors": {
            "adaptive_notch": {"type": "filter_type", "purpose": "adaptive_filtering"},
            "artifact_detector": {"type": "segmenter_type", "purpose": "artifact_detection"},
            "pca_transformer": {"type": "extractor_type", "purpose": "dimensionality_reduction"},
            "wavelet_analyzer": {"type": "extractor_type", "purpose": "time_frequency_analysis"},
            "svm_classifier": {"type": "aggregator_type", "purpose": "svm_classification"},
            "quality_assessor": {"type": "aggregator_type", "purpose": "quality_assessment"},
        }
    })
    
    # ECG Test Case 4: Signal Quality Assessment (Pipeline 9)
    test_cases.append({
        "name": "signal_quality",
        "description": "ECG Signal Quality Assessment and Reliability Pipeline",
        "slots": [
            {"input": "ts", "output": "ts", "purpose": "bandpass_filtering"},
            {"input": "ts", "output": "seg", "purpose": "segmentation"},
            {"input": "seg", "output": "seg", "purpose": "quality_assessment"},
            {"input": "seg", "output": "seg", "purpose": "artifact_removal"},
            {"input": "seg", "output": "feat", "purpose": "quality_quantification"},
            {"input": "feat", "output": "sc", "purpose": "reliability_marking"},
        ],
        "relevant_blocks": {
            "bandpass_filter": {"type": "filter_type", "purpose": "bandpass_filtering"},
            "signal_segmenter": {"type": "segmenter_type", "purpose": "segmentation"},
            "quality_assessor": {"type": "segmenter_type", "purpose": "quality_assessment"},
            "artifact_remover": {"type": "segmenter_type", "purpose": "artifact_removal"},
            "quality_quantifier": {"type": "extractor_type", "purpose": "quality_quantification"},
            "reliability_marker": {"type": "aggregator_type", "purpose": "reliability_marking"},
        },
        "distractors": {
            "notch_filter": {"type": "filter_type", "purpose": "notch_filtering"},
            "baseline_corrector": {"type": "filter_type", "purpose": "baseline_correction"},
            "beat_detector": {"type": "segmenter_type", "purpose": "beat_detection"},
            "hrv_extractor": {"type": "extractor_type", "purpose": "hrv_extraction"},
            "peak_detector": {"type": "extractor_type", "purpose": "peak_detection"},
            "compressor": {"type": "aggregator_type", "purpose": "compression"},
            "visualizer": {"type": "aggregator_type", "purpose": "visualization"},
        }
    })
    
    # ECG Test Case 5: Biometric Authentication (Pipeline 10)
    test_cases.append({
        "name": "biometric_auth",
        "description": "ECG Biometric Authentication Pipeline",
        "slots": [
            {"input": "ts", "output": "ts", "purpose": "preprocessing"},
            {"input": "ts", "output": "seg", "purpose": "beat_segmentation"},
            {"input": "seg", "output": "seg", "purpose": "beat_alignment"},
            {"input": "seg", "output": "feat", "purpose": "fiducial_detection"},
            {"input": "feat", "output": "feat", "purpose": "feature_extraction"},
            {"input": "feat", "output": "feat", "purpose": "dimensionality_reduction"},
            {"input": "feat", "output": "sc", "purpose": "biometric_matching"},
        ],
        "relevant_blocks": {
            "ecg_preprocessor": {"type": "filter_type", "purpose": "preprocessing"},
            "beat_segmenter": {"type": "segmenter_type", "purpose": "beat_segmentation"},
            "beat_aligner": {"type": "segmenter_type", "purpose": "beat_alignment"},
            "fiducial_detector": {"type": "extractor_type", "purpose": "fiducial_detection"},
            "feature_extractor": {"type": "extractor_type", "purpose": "feature_extraction"},
            "lda_reducer": {"type": "extractor_type", "purpose": "dimensionality_reduction"},
            "gmm_matcher": {"type": "aggregator_type", "purpose": "biometric_matching"},
        },
        "distractors": {
            "bandpass_filter": {"type": "filter_type", "purpose": "bandpass_filtering"},
            "notch_filter": {"type": "filter_type", "purpose": "notch_filtering"},
            "qrs_detector": {"type": "segmenter_type", "purpose": "qrs_detection"},
            "hrv_analyzer": {"type": "extractor_type", "purpose": "hrv_analysis"},
            "spectral_analyzer": {"type": "extractor_type", "purpose": "spectral_analysis"},
            "statistical_aggregator": {"type": "aggregator_type", "purpose": "statistical_analysis"},
            "anomaly_detector": {"type": "aggregator_type", "purpose": "anomaly_detection"},
        }
    })
    
    return test_cases

def run_lama_test(problem_file):
    """Run LAMA planner on a specific test case."""
    print(f"\n🔬 Testing: {problem_file}")
    
    # Run LAMA
    cmd = ["./lama_planner/fast-downward.py", "--alias", "lama", "domain_expressive.pddl", problem_file]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    
    if result.returncode == 0:
        print(f"✅ SUCCESS: Solution found for {problem_file}")
        
        # Check if plan file exists
        plan_files = [f for f in os.listdir('.') if f.startswith('sas_plan')]
        if plan_files:
            with open(plan_files[0], 'r') as f:
                plan = f.read().strip()
            print(f"📋 Plan ({len(plan.split())} steps):")
            for step in plan.split('\n'):
                if step.strip():
                    print(f"   {step}")
        
        return True
    else:
        print(f"❌ FAILED: No solution found for {problem_file}")
        print(f"Error output: {result.stderr[:200]}...")
        return False

def main():
    """Main function to generate and test ECG pipeline test cases."""
    print("🧬 ECG Pipeline Test Suite Generator")
    print("=" * 50)
    
    # Analyze ECG examples and create test cases
    test_cases = analyze_ecg_examples()
    
    successful_tests = 0
    total_tests = len(test_cases)
    
    print(f"\n📝 Generated {total_tests} test cases:")
    for case in test_cases:
        print(f"  - {case['name']}: {case['description']}")
    
    print(f"\n🏗️  Creating PDDL problem files...")
    
    # Create and test each case
    for case in test_cases:
        try:
            # Create the test case
            problem_file = create_test_case(
                case['name'], 
                case['description'], 
                case['slots'], 
                case['relevant_blocks'], 
                case['distractors']
            )
            
            print(f"\n📄 Created: {problem_file}")
            print(f"   Slots: {len(case['slots'])}")
            print(f"   Relevant blocks: {len(case['relevant_blocks'])}")
            print(f"   Distractor blocks: {len(case['distractors'])}")
            print(f"   Total search space: {len(case['relevant_blocks']) + len(case['distractors'])} blocks")
            
            # Test with LAMA
            if run_lama_test(problem_file):
                successful_tests += 1
                
        except Exception as e:
            print(f"❌ Error processing {case['name']}: {e}")
    
    print(f"\n🎯 Test Results Summary:")
    print(f"   Successful: {successful_tests}/{total_tests}")
    print(f"   Success rate: {(successful_tests/total_tests*100):.1f}%")
    
    if successful_tests == total_tests:
        print(f"\n🎉 All ECG test cases passed! The planner successfully handled:")
        print(f"   ✓ Different pipeline lengths ({min(len(c['slots']) for c in test_cases)}-{max(len(c['slots']) for c in test_cases)} slots)")
        print(f"   ✓ Various ECG processing tasks")
        print(f"   ✓ Large search spaces with distractor blocks")
        print(f"   ✓ Complex data flow constraints")
    else:
        print(f"\n⚠️  Some tests failed. Check the PDDL domain or problem definitions.")

if __name__ == "__main__":
    main() 