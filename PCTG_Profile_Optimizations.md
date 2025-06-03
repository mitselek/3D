# PCTG Profile Optimizations Summary

## Final Profile

### Extrudr PCTG Core One v2.0 Organized (`Extrudr_PCTG_Core_One_v2_organized.ini`)

The definitive PCTG profile with comprehensive documentation and optimizations based on Bambu Labs proven settings.

## Key Optimizations Applied

### 1. Enhanced Bridge Cooling

- **Changed:** `bridge_fan_speed = 70,70,70,70,70` (was 60%)
- **Benefit:** Better bridge quality and reduced stringing on overhangs
- **Reason:** PCTG benefits from more aggressive cooling on bridges while maintaining good layer adhesion

### 2. Improved Wipe Before Retraction

- **Changed:** `filament_retract_before_wipe = 30%,30%,30%,30%,30%` (was 20%)
- **Benefit:** Better seam quality and reduced oozing
- **Reason:** More thorough wiping before retraction helps with PCTG's tendency to string

### 3. Optimized Layer Time Threshold (v2.0 only)

- **Changed:** `slowdown_below_layer_time = 8,8,8,8,8` (was 10s)
- **Benefit:** Better layer cooling without excessive slowdown
- **Reason:** PCTG doesn't need as much cooling time as PLA, so 8s is more appropriate

## Maintained Bambu Labs Settings

### Core Temperature Settings

- **Nozzle Temperature:** 268°C
- **First Layer Temperature:** 260°C  
- **Bed Temperature:** 80°C (first layer and subsequent)

### Pressure Advance

- **Value:** 0.03 (increased for better precision)
- **Implementation:** Set via start G-code `M572 S0.03`

### Retraction Settings

- **Length:** 0.8mm
- **Speed:** 35mm/s
- **Deretract Speed:** 25mm/s (slightly slower for better control)
- **Z-Hop:** 0.15mm
- **Layer Change Retraction:** Enabled

### Cooling Strategy

- **Fan Speed Range:** 30-50%
- **Disable Fan First Layers:** 3
- **Full Fan Speed Layer:** 5
- **Fan Below Layer Time:** 25s

## Testing Recommendations

1. **Import Profile into PrusaSlicer**
   - Test basic print quality with simple geometric shapes
   - Check seam placement and quality
   - Verify temperature stability

2. **Fine-tune if needed:**
   - **If stringing occurs:** Increase retraction length to 1.0mm
   - **If layer adhesion issues:** Reduce bridge_fan_speed to 65%
   - **If seams are visible:** Use print profile with random seam positioning

3. **Advanced Testing:**
   - Print bridging test to verify 70% bridge fan speed
   - Test overhang performance
   - Verify pressure advance with sharp corners

## Seam Hiding Strategy

Note: Seam hiding is primarily controlled by **print profiles**, not filament profiles. For optimal seam hiding with PCTG:

1. Set `seam_position = random` in print profile
2. Enable `staggered_inner_seams = 1` in print profile  
3. Use the optimized retraction settings in this filament profile
4. Consider `seam_position = aligned` for functional parts where aesthetics matter less

## Profile Compatibility

- **Printer:** Prusa Core One / Core One MMU3
- **Nozzle:** 0.4mm High Flow
- **Filament:** Extrudr PCTG (should work with other PCTG brands)
- **PrusaSlicer:** 2.9.2+

## Installation

1. Copy the `.ini` file to your PrusaSlicer filament profiles directory
2. Restart PrusaSlicer
3. Select the profile from the filament dropdown
4. Pair with appropriate Core One print and printer profiles

---
*Generated: June 2, 2025*
*Profile optimized for high-quality PCTG printing with minimal visible seams*
