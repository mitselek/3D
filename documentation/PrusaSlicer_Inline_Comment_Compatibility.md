# PrusaSlicer Inline Comment Compatibility Guide

## Overview

This document catalogs which parameters and sections in PrusaSlicer INI configuration files support inline semicolon comments and which require block comments for proper parsing.

**Testing Environment:**

- PrusaSlicer Version: 2.9.2
- Test Date: June 3, 2025
- Test Profile: Extrudr PCTG Core One v2.0

## General Rules

### 🔍 **Key Insight: No Consistent Pattern**

The inline comment compatibility appears to be **inconsistent by design** - likely reflecting the evolutionary development of PrusaSlicer's configuration parser. Parameters added at different points in the software's history probably use different validation and parsing logic implementations.

### ✅ **Default Behavior: Most Parameters Support Inline Comments**

The vast majority of parameters support inline semicolon comments, including multi-line formats:

**Standard inline comments:**

```ini
temperature = 268                      ; Main printing temperature
filament_retract_length = 0.8          ; Retraction distance
extrusion_multiplier = 0.95            ; Slight under-extrusion for cleaner prints
```ini

**Multi-line inline comments (two supported formats):**

```ini
# Format 1: Continuation lines (aligned indentation)
min_fan_speed = 30 ; Minimum fan speed: 30% provides gentle cooling without thermal shock
                   ; PCTG benefits from consistent airflow rather than aggressive bursts

# Format 2: Separate comment lines following parameter
max_fan_speed = 50 ; Maximum fan speed: 50% limit prevents over-cooling
; Higher speeds can cause layer adhesion issues with PCTG
```ini

## ❌ **Exceptions: Parameters That Require Block Comments**

The following parameters do **NOT** support inline semicolon comments and must use block comments:

### Cooling Section

```ini
# Enable part cooling fan system
cooling = 1

# Keep fan running continuously for consistent temperature control
fan_always_on = 1
```ini

### Material Properties

```ini
# Non-abrasive material
filament_abrasive = 0

# Not water soluble
filament_soluble = 0
```ini

## Best Practices

### 🎯 **Understanding the Inconsistency**

The inline comment compatibility is **evolutionary rather than systematic**. Parameters added at different points in PrusaSlicer's development use different parsing implementations. This explains why there's no reliable pattern - it's based on **when each parameter was implemented**, not logical design.

**Practical Approach:**

1. **Default to inline comments** - Most parameters support them
2. **Test individually** - When you encounter parsing errors, switch to block comments

### Quick Reference

**✅ Use inline comments for:**

- Standard parameter documentation
- Single-line explanations
- Multi-line comments with proper formatting

**❌ Use block comments for:**

- The few exceptions listed above (`cooling`, `fan_always_on`, `filament_abrasive`, `filament_soluble`)
- Section headers and introductory text

### Documentation Style

```ini
# Section headers as block comments
parameter = value                       ; Simple inline explanation
parameter2 = value ; Multi-line inline explanation with proper continuation
                   ; continues on aligned lines with semicolons
```ini

## Profile Validation

Always test your profile by importing it into PrusaSlicer and checking that all settings load correctly.

## Key Takeaway

**Most parameters support inline comments.** Only a few specific parameters require block comments, likely due to PrusaSlicer's evolutionary development. When in doubt, try inline comments first - if you get parsing errors, switch to block comments for those specific parameters.

## Contributing

If you discover additional parameters or sections with inline comment compatibility issues, please document them using the same format and testing methodology outlined in this guide.
