#!/bin/bash
# Workspace Restructure Implementation Script
# Run this script to reorganize your 3D printing workspace

set -e  # Exit on any error

echo "🔧 Starting 3D Printing Workspace Restructure..."

# Get the current directory
WORKSPACE_DIR="/home/michelek/Documents/github/3D"
cd "$WORKSPACE_DIR"

echo "📁 Creating new directory structure..."

# Create the new organized structure
mkdir -p profiles/filament/PCTG
mkdir -p profiles/printer/Core_One
mkdir -p documentation
mkdir -p tools/bgcode

echo "📄 Moving files to organized structure..."

# Move filament profiles
mv "Extrudr_PCTG_Core_One_v2_organized.ini" "profiles/filament/PCTG/"
mv "Extrudr_PCTG_Bambu_Lab_A1_mini_0_4_nozzle_716bfe36ac.json" "profiles/filament/PCTG/"

# Move printer profiles
mv "Core_One_structure.ini" "profiles/printer/Core_One/"

# Move documentation
mv "PCTG_Profile_Optimizations.md" "documentation/"
mv "PCTG_Profile_Testing_Guide.md" "documentation/"
mv "PCTG_Project_Summary.md" "documentation/"
mv "PrusaSlicer_Inline_Comment_Compatibility.md" "documentation/"

# Move tools (if bgcode_analyzer.py exists)
if [ -f "bgcode_analyzer.py" ]; then
    mv "bgcode_analyzer.py" "tools/bgcode/"
fi

echo "🗑️  Removing empty directories..."
# Remove empty core one directory
rmdir "core one" 2>/dev/null || true

echo "📝 Creating README files..."

# Create main README
cat > README.md << 'EOF'
# 3D Printing Profiles & Documentation

A comprehensive collection of 3D printing profiles, configurations, and documentation for various printers and materials.

## Repository Structure

```
├── profiles/           # Printer and filament profiles
│   ├── filament/      # Material-specific settings
│   └── printer/       # Printer-specific configurations
├── documentation/     # Guides and optimization notes
└── tools/            # Utilities and helper scripts
```

## Featured Content

### PCTG Filament Profiles
- **Extrudr PCTG Core One v2.0**: Optimized profile with comprehensive documentation
- **Bambu Lab A1 Mini**: JSON profile for A1 Mini compatibility

### Documentation
- Complete PCTG optimization guide
- Testing procedures and best practices
- PrusaSlicer compatibility notes

## Quick Start

1. Browse `profiles/` for your printer/material combination
2. Check `documentation/` for setup guides and optimization tips
3. Use tools in `tools/` for advanced analysis

## Related Repositories

- [A1 Mini Configurations](../a1-mini-configs/) - A1 Mini specific G-code and configs

EOF

# Create profiles README
cat > profiles/README.md << 'EOF'
# 3D Printing Profiles

This directory contains printer and filament profiles for various 3D printing setups.

## Directory Structure

- `filament/` - Material-specific profiles (PCTG, PLA, PETG, etc.)
- `printer/` - Printer-specific base configurations

## Usage

1. Choose your material from `filament/`
2. Select appropriate printer configuration from `printer/`
3. Import profiles into your slicer software
4. Refer to documentation for optimization tips

EOF

# Create filament README
cat > profiles/filament/README.md << 'EOF'
# Filament Profiles

Material-specific printing profiles optimized for quality and reliability.

## Available Materials

- **PCTG** - High-quality profiles for PCTG printing

Each material directory contains:
- Slicer-specific profile files
- Material-specific documentation
- Optimization notes and test results

EOF

# Create PCTG README
cat > profiles/filament/PCTG/README.md << 'EOF'
# PCTG Filament Profiles

Optimized PCTG profiles for different printer configurations.

## Available Profiles

### Core One Profiles
- `Extrudr_PCTG_Core_One_v2_organized.ini` - Comprehensive PrusaSlicer profile
  - Temperature: 268°C nozzle, 260°C first layer, 80°C bed
  - Extrusion multiplier: 0.92 for optimal quality
  - Enhanced bridge cooling and seam optimization
  - Based on proven Bambu Labs settings

### A1 Mini Profiles  
- `Extrudr_PCTG_Bambu_Lab_A1_mini_0_4_nozzle_*.json` - Bambu Studio profile

## Quick Setup

1. Import the appropriate profile for your printer
2. Review temperature settings for your specific PCTG brand
3. Run test prints to validate settings
4. See documentation folder for detailed optimization guides

EOF

# Create printer README
cat > profiles/printer/README.md << 'EOF'
# Printer Profiles

Base printer configurations and structures.

## Available Printers

- **Core_One** - Prusa Core One printer configurations

Each printer directory contains:
- Base printer settings
- Hardware-specific configurations
- Compatibility notes

EOF

echo "🎯 Handling A1-mini repository separation..."

# Check if A1-mini exists and has content
if [ -d "A1-mini" ]; then
    echo "📋 A1-mini directory found. You have two options:"
    echo ""
    echo "Option 1: Move A1-mini to separate workspace location"
    echo "   - Recommended for clean separation"
    echo "   - Run: mv A1-mini ../a1-mini-configs"
    echo ""
    echo "Option 2: Configure as proper git submodule"
    echo "   - Keeps everything in one workspace"
    echo "   - Requires additional git setup"
    echo ""
    echo "⚠️  Currently A1-mini is causing git conflicts."
    echo "⚠️  Please choose one option and run the appropriate commands."
    echo ""
    echo "For Option 1 (recommended):"
    echo "   cd '$WORKSPACE_DIR'"
    echo "   mv A1-mini ../a1-mini-configs"
    echo "   git add ."
    echo "   git commit -m 'Restructure workspace and separate A1-mini configs'"
    echo ""
fi

echo "✅ Basic restructure complete!"
echo ""
echo "📁 New structure created:"
find . -type d -not -path "./.git*" -not -path "./A1-mini*" | sort

echo ""
echo "🔄 Next steps:"
echo "1. Review the new structure"
echo "2. Handle A1-mini separation (see options above)" 
echo "3. Add and commit changes to git"
echo "4. Update any external references to moved files"

EOF
