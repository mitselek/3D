# 3D Printing Workspace Restructure Plan

## Current Issues
- A1-mini is a nested git repo but not a proper submodule
- Mixed content types in single repository
- Git showing submodule conflicts

## Recommended Structure: Separate Repositories

### Main Repository: `3d-printing-profiles`
**Purpose:** Central hub for filament profiles and documentation
**Location:** `/home/michelek/Documents/github/3D/`

```
3d-printing-profiles/
├── README.md                              # Main project overview
├── .gitignore                            # Proper gitignore
├── profiles/
│   ├── filament/
│   │   ├── PCTG/
│   │   │   ├── Extrudr_PCTG_Core_One_v2_organized.ini
│   │   │   ├── Extrudr_PCTG_Bambu_Lab_A1_mini_0_4_nozzle_716bfe36ac.json
│   │   │   └── README.md
│   │   └── README.md
│   ├── printer/
│   │   ├── Core_One/
│   │   │   ├── Core_One_structure.ini
│   │   │   └── README.md
│   │   └── README.md
│   └── README.md
├── documentation/
│   ├── PCTG_Profile_Optimizations.md
│   ├── PCTG_Profile_Testing_Guide.md
│   ├── PCTG_Project_Summary.md
│   └── PrusaSlicer_Inline_Comment_Compatibility.md
└── tools/
    └── bgcode/                           # BGCode analysis tools
        └── bgcode_analyzer.py
```

### Separate Repository: `a1-mini-configs`
**Purpose:** A1 Mini specific configurations and G-code
**Location:** Keep as separate repo, don't nest

```
a1-mini-configs/
├── README.md
├── gcode/
│   ├── start/
│   │   ├── A1_mini_start.gcode
│   │   └── A1_mini_original_start.gcode
│   └── end/
│       ├── A1_mini_end.gcode
│       └── A1_mini_original_end.gcode
├── profiles/
└── documentation/
```

## Implementation Steps

### Step 1: Clean Up Current Repository
1. Remove A1-mini from main repo (resolve git submodule issue)
2. Create proper .gitignore
3. Restructure remaining files into organized folders

### Step 2: Set Up A1-mini as Separate Repo
1. Move A1-mini to separate location
2. Set up as independent repository
3. Add proper README and structure

### Step 3: Update Documentation
1. Update all cross-references
2. Add navigation between repositories
3. Create main README with project overview

## Benefits of This Structure

1. **Clear Separation:** Each printer/project has its own repo
2. **No Git Conflicts:** No nested repository issues
3. **Better Organization:** Logical grouping of related files
4. **Easier Maintenance:** Each repo can have its own lifecycle
5. **Collaboration Friendly:** Others can fork specific parts they need

## Alternative: Single Repository with Submodules

If you prefer everything in one place:
1. Properly configure A1-mini as a git submodule
2. Use the same folder structure but keep A1-mini as submodule
3. More complex but keeps everything connected

## Recommendation

I recommend **Option 1 (Separate Repositories)** because:
- Simpler git management
- Cleaner separation of concerns
- Each printer config can evolve independently
- Better for sharing specific configurations
