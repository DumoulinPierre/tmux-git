#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

main() {
  (cd $(pane_pwd) && sh "$CURRENT_DIR/test.sh")
}
main
