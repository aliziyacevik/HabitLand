# Phase 3: App Store Readiness - Validation

**Phase type:** Content and configuration (minimal code changes)

## Validation Approach

This phase is primarily content creation (metadata text, screenshot compositions, legal URL verification, CPP documentation). Automated test suites are not applicable for most deliverables.

Verification is embedded directly in each plan's task `<verify>` blocks:

### Plan 03-01 (Metadata & Legal)
- **Automated:** Character count validation for subtitle (<=30) and keywords (<=100) via shell commands
- **Automated:** File existence checks for all 8 metadata files
- **Automated:** Grep verification that GeneralSettingsView.swift contains legal URL links
- **Automated:** `xcodebuild build` confirms app compiles after settings changes

### Plan 03-02 (Screenshots)
- **Automated:** `xcodebuild build-for-testing` confirms ScreenshotTests.swift compiles
- **Automated:** `generate_screenshots.py` runs and produces 24 PNGs across 4 directories
- **Automated:** Pillow dimension assertions verify exact pixel sizes (1290x2796, 1242x2208)
- **Human checkpoint:** Visual quality review of all generated screenshots

## No Separate Test Suite Needed

Unlike code-heavy phases, this phase's outputs are text files, images, and configuration documents. The task-level verify commands provide sufficient automated validation. The human checkpoint in Plan 03-02 covers visual quality that cannot be automated.
