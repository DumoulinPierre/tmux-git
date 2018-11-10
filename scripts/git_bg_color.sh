#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

git_low_bg_color=""
git_medium_bg_color=""
git_high_bg_color=""

git_low_default_bg_color="#[bg=green]"
git_medium_default_bg_color="#[bg=yellow]"
git_high_default_bg_color="#[bg=red]"

get_bg_color_settings() {
	git_low_bg_color=$(get_tmux_option "@git_low_bg_color" "$git_low_default_bg_color")
	git_medium_bg_color=$(get_tmux_option "@git_medium_bg_color" "$git_medium_default_bg_color")
	git_high_bg_color=$(get_tmux_option "@git_high_bg_color" "$git_high_default_bg_color")
}

print_bg_color() {
  echo "$git_medium_bg_color"
	# local git_percentage=$($CURRENT_DIR/git_percentage.sh | sed -e 's/%//')
	# local git_load_status=$(git_load_status $git_percentage)
	# if [ $git_load_status == "low" ]; then
	# 	echo "$git_low_bg_color"
	# elif [ $git_load_status == "medium" ]; then
	# 	echo "$git_medium_bg_color"
	# elif [ $git_load_status == "high" ]; then
	# 	echo "$git_high_bg_color"
	# fi
}

main() {
	get_bg_color_settings
	print_bg_color
}
main
