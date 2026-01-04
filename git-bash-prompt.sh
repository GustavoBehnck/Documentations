#!/usr/bin/bash

# Defining used colours 
RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
OCHRE="\033[38;5;95m"
WHITE="\033[0;37m"
RESET="\033[0m"

# Picking colors
git_color() { 
	local git_status="$(git status 2> /dev/null)"
	
	if [[ $git_status =~ "not staged for commit" ]]; then
		echo -e $RED
	elif [[ $git_status =~ "to be committed" ]]; then
		echo -e $YELLOW
	elif [[ $git_status =~ "nothing to commit" ]]; then
		echo -e $GREEN
	else
		echo -e $OCHRE
	fi
}

# Making the terminal easier to see
git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
# only shows last two folders
export PROMPT_DIRTRIM=2

PS1="\u@\h \[$OCHRE\]\w"
PS1+="\[\$(git_color)\]"
PS1+="\$(git_branch)"
PS1+="\[$GREEN\] \$\[$RESET\] "

export PS1

