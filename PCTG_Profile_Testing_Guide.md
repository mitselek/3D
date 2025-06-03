# PCTG Profile Testing Guide

## Profile Status: READY FOR TESTING ✅

The optimized PCTG profile has been successfully created with comprehensive documentation. All inline comment issues have been resolved.

## Available Profile

### Organized Educational Profile (PrusaSlicer Ready)

**File:** `Extrudr_PCTG_Core_One_v2_organized.ini`

- **Format:** Well-commented with section headers and detailed explanations
- **Status:** ✅ Fixed - inline comments removed, now PrusaSlicer compatible
- **Use:** Production-ready profile with educational documentation for learning and customization

## Key Optimizations Applied

### 🎯 Seam Hiding Enhancements

- **Wipe Before Retraction:** Increased from 20% to 30% for cleaner seams
- **Layer Change Retraction:** Enabled for consistent seam quality
- **Z-hop:** 0.15mm for better seam positioning

### 🌉 Bridge Quality Improvements

- **Bridge Fan Speed:** Increased from 60% to 70% for better overhangs
- **Cooling Balance:** Optimized for PCTG's thermal properties

### ⏱️ Layer Time Optimization

- **Slowdown Threshold:** Reduced from 10s to 8s for better cooling balance
- **Fan Control:** Smart layered approach (no fan for first 3 layers)

### 🔧 Bambu Labs Core Settings (Maintained)

- **Temperature:** 268°C nozzle, 260°C first layer, 80°C bed
- **Pressure Advance:** 0.02 (set via start G-code)
- **Retraction:** 0.8mm length, 35mm/s speed, 25mm/s deretract

## Testing Instructions

### Import into PrusaSlicer

1. Open PrusaSlicer
2. Go to **Configuration → Manage Profiles**
3. Select **Filament** tab
4. Click **Import** and select `Extrudr_PCTG_Core_One_v2_organized.ini`
5. The profile will be available for use with detailed documentation

### Test Print Recommendations

1. **Calibration Tower:** Test temperature range around 268°C
2. **Overhang Test:** Validate bridge fan speed optimization
3. **Seam Test:** Print cylinder to check seam quality
4. **Layer Adhesion:** Test with complex geometry

### Quality Validation Checklist

- [ ] Seam visibility (should be minimal)
- [ ] Bridge quality (overhangs up to 45°)
- [ ] Layer adhesion (no delamination)
- [ ] Surface finish (smooth, no over-extrusion)
- [ ] First layer adhesion (should stick well)

## Troubleshooting

### If Import Fails

- Ensure file encoding is UTF-8
- Check for any remaining inline comments
- Verify file is not corrupted

### If Print Quality Issues

1. **Poor bridges:** Consider increasing bridge fan speed to 80%
2. **Visible seams:** Try increasing wipe percentage to 35%
3. **Warping:** Increase bed temperature to 85°C
4. **Stringing:** Fine-tune retraction length (0.6-1.0mm range)

## Next Steps

1. Import profile into PrusaSlicer
2. Run test prints
3. Fine-tune based on results
4. Document any adjustments for future reference

---
*Profile created: June 2, 2025*  
*Based on Bambu Labs PCTG settings with Core One optimizations*
