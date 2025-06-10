# Three-Layer HTN Planning Architecture

## Overview

This implements a **purpose-based, IO-based, and parameter-based** planning system for biosignal processing pipelines using HTN (Hierarchical Task Networks).

## Key Innovation

**Problems specify WHAT you want, Domain specifies HOW to achieve it.**

### Before (Implementation-focused):
```lisp
;; Problem had to specify exact blocks
(block-used bandpass_filter slot1)
(block-used resampler slot2)
```

### After (Intention-focused):
```lisp
;; Problem specifies goals and constraints
(step-spec step1 denoising 
  ((low_freq 0.5) (high_freq 45.0))
  ((output-hint signal)))
```

## Three-Layer Architecture

### Layer 1: Purpose-Based Planning
- **Input**: High-level purposes (denoising, resampling, etc.)
- **Output**: Candidate blocks that can achieve each purpose
- **Logic**: Match block capabilities to step requirements

### Layer 2: IO-Based Planning
- **Input**: Sequence of selected blocks
- **Output**: Type-compatible pipeline with converters inserted
- **Logic**: 
  - Check input_type → output_type compatibility
  - Insert converter blocks when types don't match
  - Handle multi-input blocks

### Layer 3: Parameter-Based Planning
- **Input**: Pipeline structure + parameter constraints
- **Output**: Fully configured pipeline
- **Logic**:
  - Apply parameter constraints from problem specification
  - Validate parameter compatibility
  - Configure reasonable defaults

## Problem File Structure

```lisp
(defproblem my-problem three-layer-biosignal
  ;; Block Knowledge Base - all available blocks
  ((block-available bandpass_filter)
   (block-purpose bandpass_filter denoising)
   (block-input-type bandpass_filter signal)
   (block-output-type bandpass_filter signal)
   (block-parameter bandpass_filter low_freq)
   ...)
  
  ;; Step Specifications - WHAT you want
  ((step-spec step1 denoising 
     ((low_freq 0.5) (high_freq 45.0))  ; Parameter constraints
     ((output-hint signal)))            ; IO hints
   ...)
  
  ;; Goal - simple pipeline specification
  ((process-pipeline (step1 step2 step3))))
```

## Key Benefits

1. **Declarative**: Specify intentions, not implementations
2. **Flexible**: Handles type mismatches by inserting converters
3. **Intelligent**: Parameter validation and configuration
4. **Scalable**: Easy to add new blocks or modify requirements

## Example: ECG Processing

**Problem says**: "I want denoising (bandpass 0.5-45Hz), then resampling (128Hz), then R-peak detection"

**Domain figures out**:
1. **Purpose**: bandpass_filter for denoising, resampler for resampling, r_peak_detector for detection
2. **IO**: signal→signal→signal→event (all compatible, no converters needed)  
3. **Parameters**: Configure bandpass(0.5, 45), resampler(128), detector(adaptive)

## Testing

- `test_simple.lisp`: 2-step pipeline (denoise → resample)
- `test_three_layer.lisp`: 5-step complex pipeline with type conversions

## Future Extensions

- **Multi-input blocks**: Automatic handling of blocks needing multiple inputs
- **Alternative synthesis**: Multiple ways to achieve the same purpose
- **Cost optimization**: Choose cheapest/fastest blocks when multiple options exist 