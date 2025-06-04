#!/usr/bin/env python3
"""
Filament Profile Comparison Tool
===============================

Compare two filament profiles supporting both:
- Bambu Labs JSON format (.json)
- PrusaSlicer INI format (.ini)

Usage:
    python profile_diff.py file1 file2 [options]

Options:
    --output-format {table,detailed,json}    Output format (default: table)
    --show-only {different,common,all}       Show only specific entries (default: different)
    --category CATEGORY                      Filter by category/section
    --ignore-comments                        Ignore comment lines in INI files
    --sort-by {key,value,file1,file2}       Sort results by field (default: key)

Examples:
    python profile_diff.py profile1.ini profile2.ini
    python profile_diff.py bambu.json prusa.ini --output-format detailed
    python profile_diff.py file1.json file2.json --show-only all --sort-by value
"""

import json
import configparser
import argparse
import sys
from pathlib import Path
from typing import Dict, Any, Tuple, List, Optional
from dataclasses import dataclass
from enum import Enum
import re

class FileFormat(Enum):
    INI = "ini"
    JSON = "json"
    UNKNOWN = "unknown"

class OutputFormat(Enum):
    TABLE = "table"
    DETAILED = "detailed" 
    JSON = "json"

class ShowMode(Enum):
    DIFFERENT = "different"
    COMMON = "common"
    ALL = "all"

@dataclass
class ProfileEntry:
    """Represents a single profile setting entry"""
    key: str
    value1: Any
    value2: Any
    category: str = ""
    file1_only: bool = False
    file2_only: bool = False
    
    @property
    def is_different(self) -> bool:
        """Check if values are different between files"""
        return str(self.value1) != str(self.value2)
    
    @property
    def is_missing(self) -> bool:
        """Check if entry exists in only one file"""
        return self.file1_only or self.file2_only

class ProfileParser:
    """Base class for profile parsers"""
    
    @staticmethod
    def detect_format(filepath: Path) -> FileFormat:
        """Detect file format based on extension and content"""
        if filepath.suffix.lower() == '.json':
            return FileFormat.JSON
        elif filepath.suffix.lower() == '.ini':
            return FileFormat.INI
        else:
            # Try to detect by content
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    first_line = f.readline().strip()
                    if first_line.startswith('{'):
                        return FileFormat.JSON
                    elif first_line.startswith('[') or '=' in first_line:
                        return FileFormat.INI
            except:
                pass
            return FileFormat.UNKNOWN
    
    @staticmethod
    def parse_file(filepath: Path, ignore_comments: bool = True) -> Dict[str, Any]:
        """Parse profile file and return normalized dictionary"""
        file_format = ProfileParser.detect_format(filepath)
        
        if file_format == FileFormat.JSON:
            return ProfileParser._parse_json(filepath)
        elif file_format == FileFormat.INI:
            return ProfileParser._parse_ini(filepath, ignore_comments)
        else:
            raise ValueError(f"Unsupported file format: {filepath}")
    
    @staticmethod
    def _parse_json(filepath: Path) -> Dict[str, Any]:
        """Parse Bambu Labs JSON profile"""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Flatten JSON structure for comparison
        flattened = {}
        
        def flatten_dict(obj, prefix=''):
            if isinstance(obj, dict):
                for key, value in obj.items():
                    new_key = f"{prefix}.{key}" if prefix else key
                    if isinstance(value, (dict, list)) and len(str(value)) > 100:
                        # For complex nested structures, store as string
                        flattened[new_key] = str(value)
                    elif isinstance(value, list) and len(value) == 1:
                        # Bambu format often uses single-item arrays
                        flattened[new_key] = value[0]
                    elif isinstance(value, list):
                        flattened[new_key] = ', '.join(str(v) for v in value)
                    else:
                        flattened[new_key] = value
            else:
                flattened[prefix] = obj
        
        flatten_dict(data)
        return flattened
    
    @staticmethod
    def _parse_ini(filepath: Path, ignore_comments: bool = True) -> Dict[str, Any]:
        """Parse PrusaSlicer INI profile"""
        config = configparser.ConfigParser(allow_no_value=True, interpolation=None)
        
        # Read file and handle comments
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # Filter out comment lines if requested
        if ignore_comments:
            filtered_lines = []
            for line in lines:
                stripped = line.strip()
                if not stripped.startswith('#') and not stripped.startswith(';'):
                    filtered_lines.append(line)
            content = ''.join(filtered_lines)
        else:
            content = ''.join(lines)
        
        # Parse INI content
        try:
            config.read_string(content)
        except configparser.Error as e:
            # Try to handle malformed INI files
            print(f"Warning: INI parsing error in {filepath}: {e}")
            # Fall back to simple key=value parsing
            return ProfileParser._parse_simple_ini(content)
        
        # Convert to flat dictionary
        flattened = {}
        for section_name in config.sections():
            for key, value in config.items(section_name):
                full_key = f"{section_name}.{key}"
                flattened[full_key] = value
        
        # Also include items without section (common in PrusaSlicer)
        if config.has_section(configparser.DEFAULTSECT):
            for key, value in config.items(configparser.DEFAULTSECT):
                flattened[key] = value
        
        return flattened
    
    @staticmethod
    def _parse_simple_ini(content: str) -> Dict[str, Any]:
        """Simple fallback parser for malformed INI files"""
        result = {}
        current_section = ""
        
        for line in content.split('\n'):
            line = line.strip()
            if not line or line.startswith('#') or line.startswith(';'):
                continue
            
            if line.startswith('[') and line.endswith(']'):
                current_section = line[1:-1]
            elif '=' in line:
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()
                
                if current_section:
                    full_key = f"{current_section}.{key}"
                else:
                    full_key = key
                
                result[full_key] = value
        
        return result

class ProfileComparator:
    """Compare two profile dictionaries"""
    
    def __init__(self, profile1: Dict[str, Any], profile2: Dict[str, Any], 
                 file1_name: str, file2_name: str):
        self.profile1 = profile1
        self.profile2 = profile2
        self.file1_name = file1_name
        self.file2_name = file2_name
    
    def compare(self) -> List[ProfileEntry]:
        """Compare profiles and return list of entries"""
        entries = []
        all_keys = set(self.profile1.keys()) | set(self.profile2.keys())
        
        for key in sorted(all_keys):
            value1 = self.profile1.get(key)
            value2 = self.profile2.get(key)
            
            # Extract category from key
            category = key.split('.')[0] if '.' in key else "root"
            
            entry = ProfileEntry(
                key=key,
                value1=value1,
                value2=value2,
                category=category,
                file1_only=(key in self.profile1 and key not in self.profile2),
                file2_only=(key in self.profile2 and key not in self.profile1)
            )
            
            entries.append(entry)
        
        return entries

class OutputFormatter:
    """Format comparison results for display"""
    
    @staticmethod
    def format_table(entries: List[ProfileEntry], file1_name: str, file2_name: str) -> str:
        """Format as table"""
        if not entries:
            return "No differences found."
        
        # Calculate column widths
        max_key_len = max(len(entry.key) for entry in entries)
        max_val1_len = max(len(str(entry.value1 or "")) for entry in entries)
        max_val2_len = max(len(str(entry.value2 or "")) for entry in entries)
        
        # Limit column widths for readability
        max_key_len = min(max_key_len, 40)
        max_val1_len = min(max_val1_len, 30)
        max_val2_len = min(max_val2_len, 30)
        
        # Header
        header = f"{'Key':<{max_key_len}} | {file1_name:<{max_val1_len}} | {file2_name:<{max_val2_len}} | Status"
        separator = "-" * len(header)
        
        lines = [header, separator]
        
        for entry in entries:
            key = entry.key[:max_key_len-3] + "..." if len(entry.key) > max_key_len else entry.key
            val1 = str(entry.value1 or "")[:max_val1_len-3] + "..." if len(str(entry.value1 or "")) > max_val1_len else str(entry.value1 or "")
            val2 = str(entry.value2 or "")[:max_val2_len-3] + "..." if len(str(entry.value2 or "")) > max_val2_len else str(entry.value2 or "")
            
            if entry.file1_only:
                status = "File1 only"
            elif entry.file2_only:
                status = "File2 only"
            elif entry.is_different:
                status = "Different"
            else:
                status = "Same"
            
            line = f"{key:<{max_key_len}} | {val1:<{max_val1_len}} | {val2:<{max_val2_len}} | {status}"
            lines.append(line)
        
        return "\n".join(lines)
    
    @staticmethod
    def format_detailed(entries: List[ProfileEntry], file1_name: str, file2_name: str) -> str:
        """Format as detailed view"""
        if not entries:
            return "No differences found."
        
        lines = []
        current_category = None
        
        for entry in entries:
            if entry.category != current_category:
                current_category = entry.category
                lines.append(f"\n=== {current_category.upper()} ===")
            
            lines.append(f"\nKey: {entry.key}")
            
            if entry.file1_only:
                lines.append(f"  {file1_name}: {entry.value1}")
                lines.append(f"  {file2_name}: <missing>")
                lines.append(f"  Status: Only in {file1_name}")
            elif entry.file2_only:
                lines.append(f"  {file1_name}: <missing>")
                lines.append(f"  {file2_name}: {entry.value2}")
                lines.append(f"  Status: Only in {file2_name}")
            else:
                lines.append(f"  {file1_name}: {entry.value1}")
                lines.append(f"  {file2_name}: {entry.value2}")
                if entry.is_different:
                    lines.append(f"  Status: Different")
                else:
                    lines.append(f"  Status: Same")
        
        return "\n".join(lines)
    
    @staticmethod
    def format_json(entries: List[ProfileEntry], file1_name: str, file2_name: str) -> str:
        """Format as JSON"""
        result = {
            "comparison": {
                "file1": file1_name,
                "file2": file2_name,
                "total_entries": len(entries),
                "different_entries": len([e for e in entries if e.is_different]),
                "file1_only": len([e for e in entries if e.file1_only]),
                "file2_only": len([e for e in entries if e.file2_only])
            },
            "entries": []
        }
        
        for entry in entries:
            entry_dict = {
                "key": entry.key,
                "category": entry.category,
                "file1_value": entry.value1,
                "file2_value": entry.value2,
                "status": "file1_only" if entry.file1_only else 
                         "file2_only" if entry.file2_only else
                         "different" if entry.is_different else "same"
            }
            result["entries"].append(entry_dict)
        
        return json.dumps(result, indent=2)

def main():
    parser = argparse.ArgumentParser(
        description="Compare two filament profiles (Bambu Labs JSON or PrusaSlicer INI)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    
    parser.add_argument("file1", type=Path, help="First profile file")
    parser.add_argument("file2", type=Path, help="Second profile file")
    parser.add_argument("--output-format", choices=["table", "detailed", "json"], 
                       default="table", help="Output format (default: table)")
    parser.add_argument("--show-only", choices=["different", "common", "all"],
                       default="different", help="Show only specific entries (default: different)")
    parser.add_argument("--category", help="Filter by category/section")
    parser.add_argument("--ignore-comments", action="store_true", default=True,
                       help="Ignore comment lines in INI files")
    parser.add_argument("--sort-by", choices=["key", "value", "file1", "file2"],
                       default="key", help="Sort results by field (default: key)")
    
    args = parser.parse_args()
    
    # Validate input files
    if not args.file1.exists():
        print(f"Error: File not found: {args.file1}", file=sys.stderr)
        sys.exit(1)
    
    if not args.file2.exists():
        print(f"Error: File not found: {args.file2}", file=sys.stderr)
        sys.exit(1)
    
    try:
        # Parse profiles
        print(f"Parsing {args.file1}...", file=sys.stderr)
        profile1 = ProfileParser.parse_file(args.file1, args.ignore_comments)
        
        print(f"Parsing {args.file2}...", file=sys.stderr)
        profile2 = ProfileParser.parse_file(args.file2, args.ignore_comments)
        
        # Compare profiles
        print("Comparing profiles...", file=sys.stderr)
        comparator = ProfileComparator(profile1, profile2, args.file1.name, args.file2.name)
        entries = comparator.compare()
        
        # Filter entries based on show_only option
        if args.show_only == "different":
            entries = [e for e in entries if e.is_different or e.is_missing]
        elif args.show_only == "common":
            entries = [e for e in entries if not e.is_different and not e.is_missing]
        # "all" shows everything, no filtering needed
        
        # Filter by category if specified
        if args.category:
            entries = [e for e in entries if e.category.lower() == args.category.lower()]
        
        # Sort entries
        if args.sort_by == "key":
            entries.sort(key=lambda x: x.key)
        elif args.sort_by == "value":
            entries.sort(key=lambda x: str(x.value1 or ""))
        elif args.sort_by == "file1":
            entries.sort(key=lambda x: str(x.value1 or ""))
        elif args.sort_by == "file2":
            entries.sort(key=lambda x: str(x.value2 or ""))
        
        # Format output
        if args.output_format == "table":
            output = OutputFormatter.format_table(entries, args.file1.name, args.file2.name)
        elif args.output_format == "detailed":
            output = OutputFormatter.format_detailed(entries, args.file1.name, args.file2.name)
        elif args.output_format == "json":
            output = OutputFormatter.format_json(entries, args.file1.name, args.file2.name)
        
        print(output)
        
        # Print summary to stderr
        total = len(entries)
        different = len([e for e in entries if e.is_different])
        file1_only = len([e for e in entries if e.file1_only])
        file2_only = len([e for e in entries if e.file2_only])
        
        print(f"\nSummary: {total} entries shown", file=sys.stderr)
        if args.show_only == "all":
            print(f"  Different: {different}", file=sys.stderr)
            print(f"  {args.file1.name} only: {file1_only}", file=sys.stderr)
            print(f"  {args.file2.name} only: {file2_only}", file=sys.stderr)
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
