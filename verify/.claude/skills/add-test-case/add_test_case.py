#!/usr/bin/env python3
"""Scaffold a new UVM leaf test case (test class + seq class + JSON entry)
for the verify environment, following its inheritance and naming
conventions. See SKILL.md in this directory for the full walkthrough.

Usage:
  python add_test_case.py --module reg --function write_read --level system
  python add_test_case.py --module efuse --function burn_and_read --level block \
      --stage1 true --smoke true --iteration 1

Creates:
  - class <module>_<function>_test in test/<module>_test.sv (system)
                                 or test/<module>_block_base_test.sv (block)
  - class <module>_<function>_seq  in seq/<module>_seq.sv (system)
                                 or seq/<module>_block_base_seq.sv (block)
  - a new entry keyed "<module>_<function>_test" in json/case/<module>.json
"""
import argparse
import json
import os
import re
import sys

MODULES = ["reg", "jls", "ro", "uart", "efuse"]

# This script lives at verify/.claude/skills/add-test-case/ -
# walk up 3 levels to reach verify (the "verify root").
VERIFY_ROOT = os.path.normpath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..")
)


def die(msg):
    print("ERROR: " + msg, file=sys.stderr)
    sys.exit(1)


def valid_ident(name):
    return re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", name) is not None


def class_exists(path, class_name):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    return re.search(r"\bclass\s+" + re.escape(class_name) + r"\b", content) is not None


def insert_before_trailing_endif_or_append(path, new_text):
    """Insert new_text before a trailing `endif guard if one exists,
    otherwise append at end of file. Handles both guarded test/*.sv files
    and unguarded seq/*.sv files with one code path."""
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    endif_idx = None
    for i in range(len(lines) - 1, -1, -1):
        if lines[i].lstrip().startswith("`endif"):
            endif_idx = i
            break
    if endif_idx is not None:
        new_lines = lines[:endif_idx] + [new_text] + lines[endif_idx:]
    else:
        new_lines = lines + [new_text]
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--module", required=True, help="one of: " + ", ".join(MODULES))
    ap.add_argument("--function", required=True, help="short scenario name, e.g. write_read (identifier chars only)")
    ap.add_argument("--level", required=True, choices=["system", "block"])
    ap.add_argument("--stage1", default=None, choices=["true", "false"])
    ap.add_argument("--stage2", default=None, choices=["true", "false"])
    ap.add_argument("--smoke", default="false", choices=["true", "false"])
    ap.add_argument("--full", default="true", choices=["true", "false"])
    ap.add_argument("--iteration", default="1")
    ap.add_argument("--codecoverage", default="true", choices=["true", "false"])
    ap.add_argument("--macro-opt", default="", dest="macro_opt",
                     help="extra +define+ tokens, appended after the block-test macro (if --level block)")
    ap.add_argument("--plusargs-opt", default="", dest="plusargs_opt")
    args = ap.parse_args()

    mod = args.module.strip().lower()
    func = args.function.strip()

    # stage1/stage2 are exclusive in every existing case entry (smoke tests are
    # stage1-only, regression tests are stage2-only) - default the one the
    # caller didn't set from the one they did, instead of letting both default
    # to "true" at once.
    if args.stage1 is None and args.stage2 is None:
        args.stage1, args.stage2 = "false", "true"
    elif args.stage1 is None:
        args.stage1 = "false" if args.stage2 == "true" else "true"
    elif args.stage2 is None:
        args.stage2 = "false" if args.stage1 == "true" else "true"

    if mod not in MODULES:
        die("--module must be one of: %s (got %r)" % (", ".join(MODULES), mod))
    if not valid_ident(func):
        die("--function must be an identifier fragment (letters/digits/underscore, "
            "not starting with a digit): %r" % func)

    test_class = "%s_%s_test" % (mod, func)
    seq_class = "%s_%s_seq" % (mod, func)

    if args.level == "system":
        test_file = os.path.join(VERIFY_ROOT, "test", "%s_test.sv" % mod)
        seq_file = os.path.join(VERIFY_ROOT, "seq", "%s_seq.sv" % mod)
        test_base = "%s_base_test" % mod
        seq_base = "%s_base_seq" % mod
        start_target = "vseqr_h.%s_seqr_h" % mod
    else:
        test_file = os.path.join(VERIFY_ROOT, "test", "%s_block_base_test.sv" % mod)
        seq_file = os.path.join(VERIFY_ROOT, "seq", "%s_block_base_seq.sv" % mod)
        test_base = "%s_block_base_test" % mod
        seq_base = "%s_block_base_seq" % mod
        start_target = "%s_env_h.vseqr_h" % mod

    if not os.path.isfile(test_file) or not os.path.isfile(seq_file):
        die(
            "Block-level base classes for module '%s' don't exist yet "
            "(missing %s and/or %s).\n"
            "Only 'efuse' has a complete, Makefile-wired block-level base today - "
            "see docs/test_case_dev_manual.md's Known Gaps section. Create the "
            "%s / %s pair first by mirroring efuse_block_base_test.sv / "
            "efuse_block_base_seq.sv, and confirm tb_top/scripts/Makefile actually "
            "selects a filelist for +define+%s_BLOCK_TEST before using this tool "
            "for module '%s' at block level."
            % (mod, test_file, seq_file, test_base, seq_base, mod.upper(), mod)
        )

    json_file = os.path.join(VERIFY_ROOT, "json", "case", "%s.json" % mod)
    if not os.path.isfile(json_file):
        die("No case file found at %s" % json_file)

    if class_exists(test_file, test_class):
        die("Class %s already exists in %s" % (test_class, test_file))
    if class_exists(seq_file, seq_class):
        die("Class %s already exists in %s" % (seq_class, seq_file))

    with open(json_file, "r", encoding="utf-8") as f:
        case_data = json.load(f)
    if test_class in case_data.get("tests", {}):
        die("Test key %s already exists in %s" % (test_class, json_file))

    # ---- test class ----
    test_text = '''
class %(test_class)s extends %(test_base)s;

  `uvm_component_utils(%(test_class)s)

  function new(string name = "%(test_class)s", uvm_component parent);
    super.new(name, parent);
  endfunction

  task main_phase(uvm_phase phase);
    %(seq_class)s seq;
    super.main_phase(phase);
    phase.raise_objection(this);
    seq = %(seq_class)s::type_id::create("seq");
    seq.start(%(start_target)s);
    phase.drop_objection(this);
  endtask

endclass : %(test_class)s
''' % dict(test_class=test_class, test_base=test_base, seq_class=seq_class,
           start_target=start_target)

    insert_before_trailing_endif_or_append(test_file, test_text)

    # ---- seq class ----
    seq_text = '''
class %(seq_class)s extends %(seq_base)s;

  `uvm_object_utils(%(seq_class)s)

  function new(string name="%(seq_class)s");
    super.new(name);
  endfunction

  task body();
    super.body();
    // TODO: real stimulus for "%(func)s" goes here
  endtask

endclass : %(seq_class)s
''' % dict(seq_class=seq_class, seq_base=seq_base, func=func)

    with open(seq_file, "a", encoding="utf-8") as f:
        f.write(seq_text)

    # ---- JSON entry ----
    macro_opt = args.macro_opt
    if args.level == "block":
        macro_opt = ("+%s_BLOCK_TEST" % mod.upper()) + macro_opt

    case_data.setdefault("tests", {})[test_class] = {
        "stage1": args.stage1,
        "stage2": args.stage2,
        "smoke": args.smoke,
        "full": args.full,
        "codecoverage": args.codecoverage,
        "iteration": args.iteration,
        "UVM_TESTNAME": test_class,
        "VCS_MACRO_OPT": macro_opt,
        "VCS_PLUSARGS_OPT": args.plusargs_opt,
    }
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(case_data, f, indent=4)
        f.write("\n")

    print("Added %s (test) to %s" % (test_class, test_file))
    print("Added %s (seq) to %s" % (seq_class, seq_file))
    print("Added JSON case '%s' to %s" % (test_class, json_file))
    print("")
    print("Next steps (see docs/test_case_dev_manual.md):")
    print("  1. Fill in %s::body() with real stimulus." % seq_class)
    print("  2. Wire real protocol signals/checks if this test needs them "
          "(interface/driver/monitor/scoreboard).")
    print("  3. Review VCS_MACRO_OPT/VCS_PLUSARGS_OPT in the new JSON entry.")
    print("  4. Run: (from sim/) ./wsim -c %s -uvm" % test_class)


if __name__ == "__main__":
    main()
