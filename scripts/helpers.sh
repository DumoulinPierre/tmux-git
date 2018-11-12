get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value="$(tmux show-option -gqv "$option")"
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

command_exists() {
	local command="$1"
	command -v "$command" &> /dev/null
}

if [[ `uname` == 'Darwin' ]]; then
    # Mac
    READLINK='greadlink -e'
else
    # Linux
    READLINK='readlink -e'
fi

# Function to build the status line. You need to define the $TMUX_STATUS
# variable.
TMUX_STATUS_DEFINITION() {
    # You can use any tmux status variables, and $GIT_BRANCH, $GIT_DIRTY,
    # $GIT_FLAGS ( which is an array of flags ), and pretty much any variable
    # used in this script :-)

    GIT_BRANCH="`basename "$GIT_REPO"`:$GIT_BRANCH"

    TMUX_STATUS="$GIT_BRANCH$GIT_DIRTY"

    echo ${GIT_FLAGS[@]}
    if [ ${#GIT_FLAGS[@]} -gt 0 ]; then
        TMUX_STATUS="$TMUX_STATUS [`IFS=,; echo "${GIT_FLAGS[*]}"`]"
    fi

}

# Taken from http://aaroncrane.co.uk/2009/03/git_branch_prompt/
find_git_repo() {
    local dir=.
    until [ "$dir" -ef / ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            GIT_REPO=`$READLINK $dir`/
            return
        fi
        dir="../$dir"
    done
    GIT_REPO=''
    return
}

find_git_branch() {
    head=$(< "$1/.git/HEAD")
    if [[ $head == ref:\ refs/heads/* ]]; then
        GIT_BRANCH=${head#*/*/}
    elif [[ $head != '' ]]; then
        GIT_BRANCH='(detached)'
    else
        GIT_BRANCH='(unknown)'
    fi
}

# Taken from https://github.com/jimeh/git-aware-prompt
find_git_dirty() {
  local status=$(git status --porcelain 2> /dev/null)
  if [[ "$status" != "" ]]; then
    GIT_DIRTY='*'
  else
    GIT_DIRTY=''
  fi
}

find_git_stash() {
    if [ -e "$1/.git/refs/stash" ]; then
        GIT_STASH='stash'
    else
        GIT_STASH=''
    fi
}

update_tmux() {

    # The trailing slash is for avoiding conflicts with repos with 
    # similar names. Kudos to https://github.com/tillt for the bug report
    CWD=`$READLINK "$(pwd)"`/

    LASTREPO_LEN=${#TMUX_GIT_LASTREPO}

    if [[ $TMUX_GIT_LASTREPO ]] && [ "$TMUX_GIT_LASTREPO" = "${CWD:0:$LASTREPO_LEN}" ]; then
        GIT_REPO="$TMUX_GIT_LASTREPO"

        # Get the info
        find_git_branch "$GIT_REPO"
        find_git_stash "$GIT_REPO"
        find_git_dirty

        GIT_FLAGS=($GIT_STASH)

        TMUX_STATUS_DEFINITION

        if [ "$GIT_DIRTY" ]; then
            # tmux set-window-option status-$TMUX_STATUS_LOCATION-attr bright > /dev/null
            printf DIRTY
        # else
            # tmux set-window-option status-$TMUX_STATUS_LOCATION-attr none > /dev/null
            # echo "2 status-$TMUX_STATUS_LOCATION-attr none > /dev/null"
        fi

        # tmux set-window-option status-$TMUX_STATUS_LOCATION "$TMUX_STATUS" > /dev/null
        # echo "3 status-$TMUX_STATUS_LOCATION "$TMUX_STATUS" > /dev/null"
        printf "$TMUX_STATUS"

    else
        find_git_repo

        if [[ $GIT_REPO ]]; then
            export TMUX_GIT_LASTREPO="$GIT_REPO"
            update_tmux
        # else
            # Be sure to unset GIT_DIRTY's bright when leaving a repository.
            # Kudos to https://github.com/danarnold for the idea
            # tmux set-window-option status-$TMUX_STATUS_LOCATION-attr none > /dev/null
            # echo "4 status-$TMUX_STATUS_LOCATION-attr none > /dev/null"

            # Set the out-repo status
            # tmux set-window-option status-$TMUX_STATUS_LOCATION "$TMUX_OUTREPO_STATUS" > /dev/null
            # echo "5 status-$TMUX_STATUS_LOCATION "$TMUX_OUTREPO_STATUS" > /dev/null"
        fi
    fi

}

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
}

git_low_fg_color=""
git_medium_fg_color=""
git_high_fg_color=""

git_low_default_fg_color="#[fg=green]"
git_medium_default_fg_color="#[fg=yellow]"
git_high_default_fg_color="#[fg=red]"

get_fg_color_settings() {
	git_low_fg_color=$(get_tmux_option "@git_low_fg_color" "$git_low_default_fg_color")
	git_medium_fg_color=$(get_tmux_option "@git_medium_fg_color" "$git_medium_default_fg_color")
	git_high_fg_color=$(get_tmux_option "@git_high_fg_color" "$git_high_default_fg_color")
}

print_fg_color() {
  printf "$git_high_fg_color"
}

print_test2() {
  pwd
}
