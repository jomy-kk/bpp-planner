# Generic HTN Domain for Biosignal Processing

## Overview

This is a completely **generic and modality-agnostic** HTN (Hierarchical Task Networks) domain for biosignal processing pipeline construction using SHOP3. Unlike the previous hardcoded approach, this domain can work with any biosignal modality and any pipeline structure.

## Key Features

### 🔧 **Blocks-Agnostic**
- Can work with any set of processing blocks provided in the problem
- No hardcoded block names or specific algorithms
- Flexible block selection based on purpose and preferences

### 🧠 **Modality-Agnostic** 
- Works with ECG, EEG, EMG, or any other biosignal type
- No hardcoded purposes or fixed pipeline structures
- Adaptable to different domain requirements

### 📏 **Structure-Flexible**
- Supports pipelines of any length (not just 5 steps)
- Handles both simple (1:1, 1:N) and complex (1+E:N) block patterns
- Automatic multi-input coordination for complex blocks

### 🎯 **Purpose-Driven**
- Block selection based on purpose compatibility
- Preference system for domain-specific optimization
- Fallback mechanisms for robustness

## Files

- **`domain_htn_shop3.lisp`** - The generic HTN domain
- **`problem_ecg_generic.lisp`** - Example ECG pipeline problem
- **`problem_eeg_generic.lisp`** - Example EEG pipeline problem
- **`test_generic_domain.lisp`** - Test suite for both examples

## Usage Examples

### Example 1: ECG Processing Pipeline

```lisp
;; ECG pipeline: denoising → resampling → r-peak detection → segmentation → normalization
((build-sequential-pipeline (denoising resampling detecting_temporal_points segmenting normalizing)))
```

**Result:**
```
(!ASSIGN-BLOCK BANDPASS_FILTER SLOT1 DENOISING)
(!ASSIGN-BLOCK RESAMPLER SLOT2 RESAMPLING)  
(!ASSIGN-BLOCK R_PEAK_DETECTOR SLOT3 DETECTING_TEMPORAL_POINTS)
(!CONNECT-SLOTS SLOT2 SLOT4)  ; Connect signal to segmenter
(!CONNECT-SLOTS SLOT3 SLOT4)  ; Connect events to segmenter
(!ASSIGN-BLOCK EPOCH_SEGMENTER SLOT4 SEGMENTING)
(!ASSIGN-BLOCK NORMALIZER SLOT5 NORMALIZING)
```

### Example 2: EEG Processing Pipeline

```lisp
;; EEG pipeline: denoising → frequency analysis → feature extraction → classification
((build-sequential-pipeline (denoising transforming_frequency_domain extracting_features classification)))
```

**Result:**
```
(!ASSIGN-BLOCK NOTCH_FILTER SLOT1 DENOISING)
(!ASSIGN-BLOCK FFT SLOT2 TRANSFORMING_FREQUENCY_DOMAIN)
(!ASSIGN-BLOCK EXTRACTING_PSD SLOT3 EXTRACTING_FEATURES)  
(!ASSIGN-BLOCK SVM_CLASSIFIER SLOT4 CLASSIFICATION)
```

## How It Works

### 1. **Generic Pipeline Building**
The domain uses recursive decomposition to build pipelines:
- `build-sequential-pipeline` → `build-pipeline` → `assign-purpose-to-slot`
- Each purpose is assigned to the next available slot
- Multi-input blocks automatically trigger connection setup

### 2. **Smart Block Selection**
- **Preferred blocks**: Domain-specific preferences (e.g., `bandpass_filter` for ECG denoising)
- **Fallback selection**: Any compatible block if no preference exists
- **Multi-input handling**: Automatic input connection for complex blocks

### 3. **Flexible Slot Management**
- Sequential slot assignment (slot1, slot2, slot3, ...)
- No predetermined pipeline length limits
- Automatic slot progression with `next-slot-number`

## Creating New Problems

To create a pipeline for a new modality or use case:

### 1. **Define Available Blocks**
```lisp
(block-available your_block)
(block-purpose your_block your_purpose)
```

### 2. **Specify Multi-Input Blocks** (if any)
```lisp
(block-io-pattern complex_block multi-input)
(required-inputs complex_block (input_slot1 input_slot2))
```

### 3. **Set Preferences** (optional)
```lisp
(preferred-block-for-purpose your_purpose preferred_block)
```

### 4. **Define Pipeline Goal**
```lisp
((build-sequential-pipeline (purpose1 purpose2 purpose3 ...)))
```

## Key Advantages

### ✅ **Separation of Concerns**
- **Domain**: Contains HOW to build pipelines (strategies)
- **Problem**: Contains WHAT to build (specific requirements)

### ✅ **Reusability**
- Same domain works for ECG, EEG, EMG, etc.
- Easy to add new modalities without changing domain

### ✅ **Flexibility**
- Any pipeline length and structure
- Any combination of blocks and purposes
- Automatic handling of complex data flow patterns

### ✅ **Maintainability**
- Single domain file to maintain
- Clear separation between generic strategies and specific requirements
- Easy to extend with new block types or purposes

## Testing

Run the test suite:
```bash
sbcl --load test_generic_domain.lisp --quit
```

This will test both ECG and EEG pipelines and show detailed debugging information.

## Comparison: Old vs New Approach

| Aspect | Old (Hardcoded) | New (Generic) |
|--------|----------------|---------------|
| **Modality Support** | ECG only | Any modality |
| **Pipeline Length** | Fixed 5 steps | Any length |
| **Block Set** | Hardcoded | Configurable |
| **Purposes** | Fixed ECG purposes | Any purposes |
| **Reusability** | Single use case | Universal |
| **Maintainability** | High coupling | Low coupling |

The new generic approach successfully addresses all the limitations of the previous hardcoded design! 