# Generic HTN Domain for designing and validating Biosignal Processing

## Overview

This is a completely **generic and modality-agnostic** HTN (Hierarchical Task Networks) domain for biosignal processing pipeline construction using SHOP3.
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
- Supports pipelines of any length
- Handles both simple (1:1, 1:N) and complex (1+E:N) block patterns
- Automatic multi-input coordination for complex blocks

### 🎯 **Purpose-Driven**
- Block selection based on purpose compatibility
- Preference system for domain-specific optimization
- Fallback mechanisms for robustness


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
sbcl --load test_example1.lisp --quit
```

