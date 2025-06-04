# Bambu Lab A1 Mini Configuration

This directory contains configuration files specific to the Bambu Lab A1 Mini 3D printer.

## Directory Structure

```text
A1_Mini/
├── gcode/
│   ├── start/          # Start G-code files
│   └── end/            # End G-code files
└── README.md           # This file
```

## G-code Files

### Start G-code

- `A1_mini_start.gcode` - Current optimized start sequence
- `A1_mini_original_start.gcode` - Original factory start sequence (backup)

### End G-code

- `A1_mini_end.gcode` - Current optimized end sequence
- `A1_mini_original_end.gcode` - Original factory end sequence (backup)

## Printer Specifications

- **Build Volume**: 180 × 180 × 180 mm
- **Nozzle Diameter**: 0.4mm (standard)
- **Bed Type**: Flexible PEI plate
- **Auto Bed Leveling**: Yes
- **Filament Detection**: Yes

## Related Files

- Filament profiles: `../../filament/PCTG/Extrudr_PCTG_Bambu_Lab_A1_mini_*.json`
- Main workspace documentation: `../../../documentation/`

## Usage Notes

1. Always backup original G-code before making modifications
2. Test new G-code sequences with small test prints first
3. Monitor first layer adhesion when changing start sequences
4. Ensure proper bed temperature cooldown in end sequences
