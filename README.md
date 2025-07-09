# Biosignal Processing Pipeline Planner

A SHOP3-based hierarchical task network (HTN) planner for automated biosignal processing pipeline construction with type safety and best practices detection.

## Overview

This system automatically constructs biosignal processing pipelines by selecting appropriate processing blocks, configuring parameters, and ensuring type compatibility between pipeline stages. It includes intelligent detection of common signal processing pitfalls such as aliasing risks.

### Key Features

- **Hierarchical Pipeline Planning**: 6-phase architecture for robust pipeline construction
- **Type Safety**: Automatic verification of signal type compatibility between blocks
- **Multi-Block Steps**: Support for complex processing steps with multiple interconnected blocks
- **Best Practices Detection**: Automated detection of signal processing violations (e.g., aliasing risks)
- **Constraint Satisfaction**: Integration with CSV-based block specifications and I/O constraints
- **Extensible Framework**: Easy addition of new processing blocks and validation rules

### Architecture

The system uses a 6-phase hierarchical planning approach:

1. **Block Selection**: Choose appropriate processing blocks for each step
2. **Parameter Configuration**: Set block parameters according to specifications
3. **Intra-Step Pipeline Planning**: Connect blocks within individual steps
4. **Boundary Validation**: Verify step I/O constraints are satisfied
5. **Inter-Step Connections**: Connect steps to form the complete pipeline
6. **Best Practices Checking**: Detect and report potential signal processing violations

---

## Requirements

- SBCL (Steel Bank Common Lisp)
- Quicklisp package manager
- SHOP3 planning system

### Installation

1. Install SBCL:
   ```bash
   # macOS (via Homebrew)
   brew install sbcl
   
   # Ubuntu/Debian
   sudo apt-get install sbcl
   ```

2. Install Quicklisp:
   ```bash
   curl -O https://beta.quicklisp.org/quicklisp.lisp
   sbcl --load quicklisp.lisp --eval "(quicklisp-quickstart:install)" --quit
   ```

3. Install SHOP3:
   ```bash
   sbcl --eval "(ql:quickload :shop3)" --quit
   ```

---

## File Structure

```
Planner/
├── domain.lisp              # Main domain definition
├── knowledge_base.csv       # Block specifications and constraints
├── simple_problem*.lisp     # Simple test problems that demonstrate feasibility
├── test_*.lisp              # Run test files
└── README.md                # This file
```

---

## How to run a test

In the terminal:
```bash
sbcl --eval "(progn (load \"test_4_step_no_rpeaks.lisp\") (quit))"
```

### Example Output

A successful pipeline plan includes parameter configurations, connections, and any detected violations:

```lisp
Plans:
(((!CONFIGURE-PARAM STEP1 LOW_FREQ 60) 1.0
  (!CONFIGURE-PARAM STEP1 FILTER_ORDER 4) 1.0
  (!CONFIGURE-PARAM STEP2 SAMPLING_RATE 128) 1.0
  (!CONFIGURE-PARAM STEP2 METHOD LINEAR) 1.0
  (!CONFIGURE-PARAM STEP3 WINDOW_SIZE 60) 1.0
  (!CONFIGURE-PARAM STEP3 WINDOW_OVERLAP 30) 1.0
  (!CONFIGURE-PARAM STEP4 OPERATION MEAN) 1.0
  (!CONNECT STEP1 STEP2) 1.0
  (!CONNECT STEP2 STEP3) 1.0
  (!CONNECT STEP3 STEP4) 1.0
))
```

---

## Test Examples

### Problem 1
**Goal:** Very simple example with a 3-step pipeline skeleton.  
**Purpose:** Tests that the planner can adapt to shorter pipelines and select appropriate blocks for different step purposes. Demonstrates block choice flexibility when fewer processing stages are needed.

### Problem 2
**Goal:** Simple example with a 5-step pipeline skeleton. Verify complete pipeline planning with block selection and parameter configuration.
**Purpose:** Tests planning capability by choosing correct blocks from 22+ available options and configuring all parameters. This is the comprehensive test for normal ECG processing workflows.

### Problem 3
**Goal:** Test domain flexibility when preferred block unavailable.
**Purpose:** Verifies the planner can find alternative solutions when a commonly-used block (bandpass filter) is not available. Tests adaptive planning and fallback strategies.

### Problem 4
**Goal:** Validate pre-existing solution with assigned blocks. 
**Purpose:** Tests the domain's ability to validate and complete solutions where blocks are already assigned. Focuses on parameter configuration and connection validation rather than block selection.

### Problem 5
**Goal:** Test type-compatible pipeline avoiding problematic signal→event transition.
**Purpose:** Verifies the planner can create valid pipelines that skip R-peak detection, going directly from signal processing to feature extraction.

### Solution 6
**Goal:** Verify aliasing risk detection when lowpass frequency > Nyquist frequency.
**Purpose:** Ensures the planner detects and reports signal processing violations. Specifically tests the aliasing risk detection when a 60Hz lowpass filter is followed by 100Hz sampling (violates Nyquist criterion since 60Hz > 50Hz Nyquist frequency).

---

## Technical Details

### Available Processing Blocks

After RAG, the problems may include blocks for:
- **Filtering**: lowpass_filter, highpass_filter, bandpass_filter, notch_filter
- **Resampling**: resampler (upsampling/downsampling)
- **Feature Extraction**: hrv_features_extractor, spectral_features_extractor
- **Event Detection**: r_peak_detector, artifact_detector
- **Aggregation**: aggregate_features (statistical operations)

### Data Types

- **signal**: Raw time-series biosignal data
- **signal-freq**: Frequency-domain signal data
- **features**: Extracted feature vectors
- **event**: Detected events/annotations
- **scalar**: Single numerical values
- **distribution**: Statistical distributions

### Domain Definition

The main domain (`domain_extended.lisp`) defines:
- HTN methods for hierarchical planning
- Operators for parameter configuration and connections
- Axioms for type compatibility and best practices detection
- Predicates for constraint satisfaction

### Problem Definition Structure

Each problem file includes:
- Available processing blocks
- Block purposes and parameters
- I/O type specifications
- Step specifications with constraints
- Pipeline structure requirements

### Type System

The type compatibility system ensures that:
- Block outputs match subsequent block inputs
- OR constraints are properly handled
- Step boundaries satisfy I/O hints
- Pipeline flow is semantically correct

---

## Extending the System

### Adding New Blocks

1. Add block availability: `(block-available new_block)`
2. Define purpose: `(block-purpose new_block new_purpose)`
3. Specify parameters: `(block-parameter new_block param_name)`
4. Set I/O types: `(block-input-type new_block input_type)` and `(block-output-type new_block output_type)`

### Adding New Best Practices

1. Define detection axiom:
   ```lisp
   (:- (bp-new-risk ?conditions)
       ((detection-logic)))
   ```

2. Add reporting operator:
   ```lisp
   (:operator (!report-new-risk ?params)
       ;; preconditions and effects
   )
   ```

3. Integrate into checking framework:
   ```lisp
   (:method (check-violation-between ?step1 ?step2)
       ((bp-new-risk ?conditions))
       ((!report-new-risk ?params)))
   ```

