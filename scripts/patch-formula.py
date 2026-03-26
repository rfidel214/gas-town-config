#!/usr/bin/env python3
"""
Patch mol-polecat-work formula to add mandatory capture-findings step.

Usage:
    python3 patch-formula.py [--gt-dir ~/gt]

Options:
    --gt-dir    Gas Town root directory (default: ~/gt)
"""
import sys
import argparse
from pathlib import Path

FORMULA_NAME = "mol-polecat-work.formula.toml"
INSERT_BEFORE = '\n[[steps]]\nid = "pre-verify"'
GUARD = 'id = "capture-findings"'

def find_script_dir():
    return Path(__file__).parent

def main():
    parser = argparse.ArgumentParser(description="Patch mol-polecat-work formula")
    parser.add_argument("--gt-dir", default="~/gt", help="Gas Town root directory")
    args = parser.parse_args()

    gt_dir = Path(args.gt_dir).expanduser()
    formula_path = gt_dir / ".beads" / "formulas" / FORMULA_NAME
    step_path = find_script_dir().parent / "formulas" / "capture-step.toml"

    if not formula_path.exists():
        print(f"ERROR: formula not found at {formula_path}")
        sys.exit(1)

    if not step_path.exists():
        print(f"ERROR: capture-step.toml not found at {step_path}")
        sys.exit(1)

    content = formula_path.read_text()

    if GUARD in content:
        print(f"SKIP: mol-polecat-work already has capture-findings step")
        sys.exit(0)

    new_step = step_path.read_text()

    idx = content.find(INSERT_BEFORE)
    if idx == -1:
        print(f"ERROR: could not find pre-verify insertion point in formula")
        sys.exit(1)

    new_content = content[:idx] + new_step + content[idx:]
    formula_path.write_text(new_content)
    print(f"OK: inserted capture-findings step before pre-verify in {FORMULA_NAME}")

    # Verify
    verify = formula_path.read_text()
    if GUARD in verify:
        import re
        steps = re.findall(r'^id = "', verify, re.MULTILINE)
        print(f"VERIFIED: capture-findings present. Total steps: {len(steps)}")
    else:
        print("ERROR: verification failed")
        sys.exit(1)

    # Remind about pre-verify needs update
    if 'needs = ["capture-findings"]' not in verify:
        print("\nNOTE: pre-verify step may need its 'needs' updated to [\"capture-findings\"].")
        print("Check the formula and update manually if needed.")

if __name__ == "__main__":
    main()
