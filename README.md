# GroupPolicyTools

A lightweight suite of Windows batch and PowerShell scripts to snapshot, track, and audit Group Policy (RSOP) changes over time.

## Overview

This toolkit allows you to:
1. **Capture** dated snapshots of your current Group Policy settings (`gpresult_YYYYMMDD.xml`).
2. **Compare** consecutive snapshots to build a timeline of what changed (Enabled/Disabled, values added/removed).
3. **Pinpoint** precise XML paths for every modified setting.

No installation required—just drop the scripts in a folder and run them.

## File Manifest

| File | Description |
| :--- | :--- |
| `gpresult_snapshot.bat` | Captures the current policy state into a date-stamped XML file. Self-elevates if needed. |
| `gpresult_timeline.bat` | Generates a simple timeline text file showing line-by-line diffs (OLD vs NEW). |
| `gpresult_timeline_paths.bat` | Wrapper for the paths script. Runs the PowerShell logic below. |
| `gpresult_timeline_paths.ps1` | Advanced comparison script that diffs XML structure and reports changed nodes with full paths. |

## Usage Workflow

### 1. Take Snapshots
Run `gpresult_snapshot.bat` whenever you want to capture the system's policy state (e.g., daily or before/after changes).

- **Action**: Generates `gpresult_20251205.xml`, `gpresult_20251206.xml`, etc.
- **Privileges**: Prompts for Admin rights if not already elevated.
- **Note**: Keep all generated XML files in the same folder as the scripts.

### 2. Audit Changes (Simple)
To see a quick line-based diff of all snapshots in chronological order:

1. Run `gpresult_timeline.bat`.
2. Open `gpresult_timeline.txt`.
3. Review the **OLD** vs **NEW** lines for every detected change.

### 3. Audit Changes (Detailed)
For a robust structural analysis that shows the **XML path** of every changed setting (e.g., `/System/Extension/PolicyName/State`):

1. Ensure `gpresult_timeline_paths.bat` and `gpresult_timeline_paths.ps1` are in the folder.
2. Run `gpresult_timeline_paths.bat`.
3. Open `gpresult_timeline_paths.txt`.

**Example Output:**

    Changes in gpresult_20251206.xml (vs gpresult_20251205.xml):

    PATH: /Computer[1]/Extension[1]/Default AutoRun Behavior[1]/q3:State[1]
    OLD: Enabled
    NEW: Disabled

## Requirements
- **OS**: Windows 10/11 or Windows Server.
- **PowerShell**: Version 5.1 or later (pre-installed on modern Windows).
- **Permissions**: Administrator rights required for `gpresult_snapshot.bat` to capture full computer policies.

## Tips
- **Automation**: You can schedule `gpresult_snapshot.bat` in Windows Task Scheduler to run daily at 9 AM.
- **Maintenance**: Old XML files can be archived or deleted; the timeline scripts simply sort and compare whatever files are present in the folder.
