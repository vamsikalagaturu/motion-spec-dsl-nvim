#!/usr/bin/env bash
set -e
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARSER_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/parser"
mkdir -p "$PARSER_DIR"
gcc -O2 -shared -fPIC \
  -o "$PARSER_DIR/robmot.so" \
  "$PLUGIN_DIR/src/parser.c" \
  -I "$PLUGIN_DIR/src/"
echo "motion-spec-dsl-nvim: parser installed to $PARSER_DIR/robmot.so"
