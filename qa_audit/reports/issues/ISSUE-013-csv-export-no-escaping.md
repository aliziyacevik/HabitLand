# Issue ID
ISSUE-013

# Title
CSV export doesn't properly escape special characters in habit names

# Category
Bug / Data

# Severity
Medium

# Priority
P2

# Screen / Feature
Settings → Privacy → Export Data (CSV)

# Preconditions
User has a habit with commas or quotes in the name (e.g., "Read, Write & Code")

# Steps to Reproduce
1. Create habit named: He said "hello", goodbye
2. Go to Settings → Privacy → Export as CSV
3. Open the exported CSV file

# Expected Result
Special characters properly escaped per RFC 4180 CSV standard

# Actual Result
Quotes and commas in habit names break CSV column alignment. The name field uses escaped quotes `\"` in Swift but doesn't double-quote per CSV spec.

# Frequency
Only with special character habit names

# Suspected Root Cause
Line 188 in PrivacySettingsView wraps name in quotes but doesn't escape internal quotes (CSV requires doubling: `""`)

# Code References
- `HabitLand/Screens/Settings/PrivacySettingsView.swift:183-198`

# Impact
Exported CSV files may be malformed when opened in Excel/Numbers if habit names contain commas or quotes.

# Recommended Fix Direction
Add a CSV escaping helper: replace `"` with `""` inside values, ensure all fields are quoted.

# Notes for Next Agent
Create a helper function like `func csvEscape(_ s: String) -> String { "\"\(s.replacingOccurrences(of: "\"", with: "\"\""))\"" }`
