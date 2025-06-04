#!/bin/bash

# Markdown Linting Script for 3D Printing Workspace
# Checks all .md files for common markdown formatting issues
#
# DEVELOPMENT PLAN (June 4, 2025):
# - Improve this linting script gradually as new errors get encountered
# - When VS Code PROBLEMS tab shows markdown issues:
#   1. Run this script first - if it reports errors, fix them
#   2. If this script shows no errors but VS Code does, enhance this script
#   3. If terminal output fails, report "eyesight struggle" and ask for help
# - Add new checks immediately when encountered
# - Collect false positives and deal with them as they appear
# - Track weird edge cases in comments below
#
# CURRENT MARKDOWN RULES CHECKED:
# - MD040: Fenced code blocks without language specification (```$)
# - MD012: Multiple consecutive blank lines (3+ blank lines in a row)
# - MD022: Headings should be surrounded by blank lines (respects code fence boundaries)
# - CUSTOM: Malformed code block closing fences (```language instead of ```)
#
# KNOWN EDGE CASES:
# - Malformed code block: ```text closing fence instead of ``` (IMPLEMENTED ✅)
#   Successfully detects lines like "```ini" when they should be just "```"
# - Trailing blank lines: Files ending with extra blank lines (IMPLEMENTED ✅)
#   Quick fix: sed -i -e :a -e '/^\s*$/N;ba' -e 's/\n*$//' filename.md
#
# FALSE POSITIVES ENCOUNTERED:
# - Fixed: MD040 incorrectly flagged closing fences (```) as missing language spec
# - Fixed: Malformed fence detection incorrectly flagged opening fences (```language) as malformed closing fences
# - Fixed: MD022 incorrectly analyzed content inside code fences (now respects fence boundaries)
#
# NOT YET IMPLEMENTED (common VS Code markdown rules):
# - MD032: Lists should be surrounded by blank lines  
# - MD031: Fenced code blocks should be surrounded by blank lines
# - MD025: Multiple top-level headings
# - MD041: First line should be a top-level heading
#
# USEFUL FIXES FOR DETECTED ISSUES:
# - To remove trailing blank lines: sed -i -e :a -e '/^\s*$/N; s/\n$//; ta' filename.md
#   (This removes all trailing blank lines in one command)

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL_FILES=0
TOTAL_ERRORS=0

echo "🔍 Markdown Linting Report"
echo "=========================="
echo "Workspace: $WORKSPACE_ROOT"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Find all markdown files
echo "📝 Scanning for markdown files..."
MD_FILES=$(find "$WORKSPACE_ROOT" -name "*.md" -type f | sort)

if [ -z "$MD_FILES" ]; then
    echo "❌ No markdown files found!"
    exit 1
fi

echo "Found markdown files:"
while IFS= read -r file; do
    if [ -n "$file" ]; then
        rel_path="${file#$WORKSPACE_ROOT/}"
        echo "   - $rel_path"
        ((TOTAL_FILES++))
    fi
done <<< "$MD_FILES"
echo ""

# Enhanced check function with line numbers
check_file() {
    local file="$1"
    local rel_path="${file#$WORKSPACE_ROOT/}"
    local issues=0
    
    echo "Checking: $rel_path"
    
    # Check for code blocks without language (with line numbers)
    # Only flag opening fences without language, not closing fences
    local code_block_lines
    code_block_lines=$(awk 'BEGIN {in_code_block=0; line_num=0} {
        line_num++
        if ($0 ~ /^```$/) {
            if (in_code_block == 0) {
                # This is an opening fence without language
                print line_num ": ```"
                in_code_block = 1
            } else {
                # This is a closing fence (valid)
                in_code_block = 0
            }
        } else if ($0 ~ /^```[a-zA-Z]/) {
            # Opening fence with language (valid)
            in_code_block = 1
        }
    }' "$file" 2>/dev/null || true)
    
    if [ -n "$code_block_lines" ]; then
        echo "  ⚠️  Code blocks without language specification:"
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                local line_num="${line%%:*}"
                echo "    Line $line_num: \`\`\`"
                ((issues++))
            fi
        done <<< "$code_block_lines"
    fi
    
    # Check for multiple consecutive blank lines and trailing blanks (improved detection)
    local blank_lines
    blank_lines=$(awk 'BEGIN {line_num=0; blank_count=0; total_lines=0} {
        line_num++
        total_lines++
        if ($0 == "") {
            blank_count++
            if (blank_count >= 2) {
                print "Line " line_num ": MD012 - Multiple consecutive blank lines (found " blank_count " consecutive)"
            }
        } else {
            blank_count = 0
        }
    } END {
        # Check for trailing blank lines
        if (blank_count > 0) {
            print "Line " total_lines ": MD012 - Trailing blank line(s) at end of file"
        }
    }' "$file" 2>/dev/null || true)
    
    if [ -n "$blank_lines" ]; then
        echo "  ⚠️  Multiple consecutive blank lines:"
        echo "$blank_lines" | sed 's/^/    /'
        issues=$((issues + $(echo "$blank_lines" | wc -l)))
    fi
    
    # Check for MD022: Headings should be surrounded by blank lines
    # Only check outside of code fences
    local heading_issues
    heading_issues=$(awk 'BEGIN {line_num=0; in_code_block=0} {
        line_num++
        
        # Track code fence state
        if ($0 ~ /^```/) {
            in_code_block = 1 - in_code_block
        }
        
        # Only check headings when not in code blocks
        if (!in_code_block && $0 ~ /^#+/) {
            # Check if heading has blank line before (except first line)
            if (line_num > 1 && prev_line != "" && !prev_was_fence) {
                print "Line " line_num ": MD022 - Heading should have blank line before"
            }
            # Check if heading has blank line after (except last line)
            getline next_line
            line_num++
            if (next_line != "" && next_line !~ /^$/ && next_line !~ /^```/) {
                print "Line " (line_num-1) ": MD022 - Heading should have blank line after"
            }
            prev_line = next_line
            prev_was_fence = (next_line ~ /^```/)
        } else {
            prev_line = $0
            prev_was_fence = ($0 ~ /^```/)
        }
    }' "$file" 2>/dev/null || true)
    
    if [ -n "$heading_issues" ]; then
        echo "  ⚠️  Heading spacing issues (MD022):"
        echo "$heading_issues" | sed 's/^/    /'
        issues=$((issues + $(echo "$heading_issues" | wc -l)))
    fi
    
    # Check for malformed code block closing fences (```language instead of ```)
    # Only flag closing fences that incorrectly have language specifications
    local malformed_fences
    malformed_fences=$(awk 'BEGIN {in_code_block=0; line_num=0} {
        line_num++
        if ($0 ~ /^```$/) {
            if (in_code_block == 0) {
                # Opening fence without language
                in_code_block = 1
            } else {
                # Closing fence (valid)
                in_code_block = 0
            }
        } else if ($0 ~ /^```[a-zA-Z]/) {
            if (in_code_block == 0) {
                # Opening fence with language (valid)
                in_code_block = 1
            } else {
                # This is a malformed closing fence with language
                print line_num ": " $0 " (should be just ```)"
                in_code_block = 0
            }
        }
    }' "$file" 2>/dev/null || true)
    
    if [ -n "$malformed_fences" ]; then
        echo "  ⚠️  Malformed code block closing fences:"
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                local line_num="${line%%:*}"
                local fence_content="${line#*:}"
                echo "    Line $line_num:$fence_content"
                ((issues++))
            fi
        done <<< "$malformed_fences"
    fi
    
    # Report results
    if [ $issues -eq 0 ]; then
        echo "  ✅ All checks passed"
    else
        ((TOTAL_ERRORS += issues))
    fi
    
    return $issues
}

# Check each file
while IFS= read -r file; do
    if [ -n "$file" ] && [ -f "$file" ]; then
        check_file "$file"
        echo ""
    fi
done <<< "$MD_FILES"

# Summary
echo "📊 Summary"
echo "=========="
echo "Total files checked: $TOTAL_FILES"
echo "Total issues found: $TOTAL_ERRORS"
echo ""

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo "🎉 All markdown files passed basic checks!"
    echo ""
    echo "💡 For detailed linting, check VS Code PROBLEMS tab"
else
    echo "⚠️  Found $TOTAL_ERRORS issue(s)"
    echo ""
    echo "💡 For detailed linting, check VS Code PROBLEMS tab"
fi

exit $TOTAL_ERRORS
