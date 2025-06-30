# Biosignal Processing Pipeline Planner

A SHOP3-based hierarchical task network (HTN) planner for automated biosignal processing pipeline construction with type safety and best practices detection.

## Overview

This system automatically constructs biosignal processing pipelines by selecting appropriate processing blocks, configuring parameters, and ensuring type compatibility between pipeline stages. It includes intelligent detection of common signal processing pitfalls such as aliasing risks.

### Key Features

- **Hierarchical Pipeline Planning**: 5-phase architecture for robust pipeline construction
- **Type Safety**: Automatic verification of signal type compatibility between blocks
- **Multi-Block Steps**: Support for complex processing steps with multiple interconnected blocks
- **Best Practices Detection**: Automated detection of signal processing violations (e.g., aliasing risks)
- **Constraint Satisfaction**: Integration with CSV-based block specifications and I/O constraints
- **Extensible Framework**: Easy addition of new processing blocks and validation rules

## Architecture

The system uses a 5-phase hierarchical planning approach:

1. **Block Selection**: Choose appropriate processing blocks for each step
2. **Parameter Configuration**: Set block parameters according to specifications
3. **Intra-Step Pipeline Planning**: Connect blocks within individual steps
4. **Boundary Validation**: Verify step I/O constraints are satisfied
5. **Inter-Step Connections**: Connect steps to form the complete pipeline
6. **Best Practices Checking**: Detect and report potential signal processing violations

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

## File Structure

```
Planner/
├── domain_extended.lisp              # Main domain definition
├── simpler_biosignal_blocks.csv      # Block specifications and constraints
├── problem_*.lisp                    # Test problems
├── test_*.lisp                       # Test files
└── README.md                         # This file
```

## Quick Start

### Basic Usage

1. **Run a simple 4-step pipeline**:
   ```bash
   sbcl --eval "(progn (load \"test_4_step_no_rpeaks.lisp\") (quit))"
   ```

2. **Test best practices detection**:
   ```bash
   sbcl --eval "(progn (load \"test_best_practices_detection.lisp\") (quit))"
   ```

3. **Validate a solution**:
   ```bash
   sbcl --eval "(progn (load \"test_4_step_validation.lisp\") (quit))"
   ```

### Example Output

A successful pipeline plan includes parameter configurations, connections, and any detected violations:

```lisp
Plans:
(((!CONFIGURE-PARAM STEP1 LOW_FREQ 60) 1.0
  (!CONFIGURE-PARAM STEP1 FILTER_ORDER 4) 1.0
  (!CONFIGURE-PARAM STEP2 SAMPLING_RATE 100) 1.0
  (!CONFIGURE-PARAM STEP2 METHOD LINEAR) 1.0
  (!CONFIGURE-PARAM STEP3 WINDOW_SIZE 60) 1.0
  (!CONFIGURE-PARAM STEP3 WINDOW_OVERLAP 30) 1.0
  (!CONFIGURE-PARAM STEP4 OPERATION MEAN) 1.0
  (!CONNECT STEP1 STEP2) 1.0
  (!CONNECT STEP2 STEP3) 1.0
  (!CONNECT STEP3 STEP4) 1.0
  (!REPORT-ALIASING-RISK STEP1 STEP2 60 100) 1.0))
```

## Test Cases

### Working Examples

- **`problem_4_step_no_rpeaks.lisp`**: Successful 4-step pipeline (denoising → resampling → feature extraction → aggregation)
- **`problem_4_step_validation.lisp`**: Solution validation with pre-loaded facts

### Type Safety Examples

- **`problem_5_step.lisp`**: Demonstrates type incompatibility (event→signal mismatch)
- **`problem_5_step_no_bandpass.lisp`**: Alternative 5-step configuration

### Best Practices Detection

- **`problem_bad_practice_aliasing.lisp`**: Demonstrates aliasing risk detection (60Hz lowpass → 100Hz downsample)

## Pipeline Components

### Available Processing Blocks

The system includes blocks for:
- **Filtering**: lowpass_filter, highpass_filter, bandpass_filter, notch_filter
- **Resampling**: resampler (upsampling/downsampling)
- **Feature Extraction**: hrv_features_extractor, spectral_features_extractor
- **Event Detection**: r_peak_detector, artifact_detector
- **Aggregation**: aggregate_features (statistical operations)

### Signal Types

- **signal**: Raw time-series biosignal data
- **signal-freq**: Frequency-domain signal data
- **features**: Extracted feature vectors
- **event**: Detected events/annotations
- **scalar**: Single numerical values
- **distribution**: Statistical distributions

## Best Practices Detection

The system automatically detects common signal processing violations:

### Aliasing Risk Detection

Identifies when a lowpass filter's cutoff frequency exceeds the Nyquist frequency of subsequent downsampling:

```lisp
;; VIOLATION: 60Hz cutoff > 50Hz Nyquist (100Hz sampling)
(!REPORT-ALIASING-RISK STEP1 STEP2 60 100)
```

**Mathematical Check**: `cutoff_frequency > (sampling_rate / 2)`

### Extensible Framework

Additional best practices can be easily added using axioms:

```lisp
(:- (bp-new-violation ?conditions)
    ((detection-logic)))

(:operator (!report-new-violation ?params)
    ;; preconditions and effects
)
```

## Running Tests

### Individual Test Files

```bash
# Basic planning tests
sbcl --eval "(progn (load \"test_4_step_no_rpeaks.lisp\") (quit))"
sbcl --eval "(progn (load \"test_5_step.lisp\") (quit))"

# Validation tests
sbcl --eval "(progn (load \"test_4_step_validation.lisp\") (quit))"

# Best practices tests
sbcl --eval "(progn (load \"test_best_practices_detection.lisp\") (quit))"
sbcl --eval "(progn (load \"test_best_practices_query.lisp\") (quit))"
```

### Clean Output Mode

For cleaner output without debug information:

```bash
sbcl --eval "(progn (load \"test_clean_output.lisp\") (quit))" --non-interactive > output.txt 2>&1
```

## Technical Details

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

