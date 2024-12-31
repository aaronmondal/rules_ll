#!/bin/bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# Revert the leaky `-uo pipefail` from the stub.
set +uo pipefail

CDF=$1
OUT=$2
CONFIG_FILE=$3

$(rlocation rules_ll/ll/cdb-merger) "$CDF" compile_commands.json

INPUT_FILE=$(sed -n 's/.*"file": "\([^"]*\)".*/\1/p' "compile_commands.json")

# Skip .pcm inputs which currently crash clang-tidy.
if [[ "$INPUT_FILE" == *.pcm ]]; then
    touch "$OUT"
    exit 0
fi

# The clang-tidy invocation.
$(rlocation llvm-project/clang-tools-extra/clang-tidy/clang-tidy) \
    --use-color \
    --quiet \
    --config-file="$CONFIG_FILE" \
    -p=. \
    "$INPUT_FILE" \
    2>error.log | tee "$OUT"

# In a happy case the error log contains "xxx warnings generated." or
# "xxx warnings generated when compiling for host.". Filter such cases so that
# we don't spam Bazel's INFO output.
#
# If clang-tidy crashes the error log is nonempty.
#
# The actual output messages of a successful clang-tidy invocation (even if it
# triggered) will be in the out file and are not handled here.
if [[ -s error.log ]] && ! grep -qE '^[0-9]+[[:space:]]warnings[[:space:]]generated([[:space:]]when[[:space:]]compiling[[:space:]]for[[:space:]]host)?[.]$' error.log; then
    cat error.log
    echo "Clang-tidy failed to run on this compile command database:"
    cat compile_commands.json
    exit 1
fi

# If we trigger a clang-tidy warning it'll print to stdout by default. If a user
# turns warnings into errors it should fail the corresponding Bazel invocation.
if grep -q "error:" "$OUT" 2>/dev/null; then
    exit 1
fi
