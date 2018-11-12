#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

main() {
  tmux showenv -g TMUX_PWD_$(tmux display -p "#D" | tr -d %)  | sed 's/^.*=//'
}
main
