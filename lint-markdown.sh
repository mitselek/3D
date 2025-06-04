#!/bin/bash

# Markdown Linting Script for 3D Printing Workspace
# Checks all .md files for common markdown formatting issues

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
    local code_block_lines
    code_block_lines=$(grep -n '^```$' "$file" 2>/dev/null || true)
    
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
    
    # Check for multiple consecutive blank lines
    local blank_lines
    blank_lines=$(grep -n '^$' "$file" 2>/dev/null | awk -F: '{
        if (prev && $1 == prev + 1 && prev2 && prev == prev2 + 1) {
            print "Line " $1 ": Multiple consecutive blank lines"
        }
        prev2 = prev; prev = $1
    }' || true)
    
    if [ -n "$blank_lines" ]; then
        echo "  ⚠️  Multiple consecutive blank lines:"
        echo "$blank_lines" | sed 's/^/    /'
        issues=$((issues + $(echo "$blank_lines" | wc -l)))
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
