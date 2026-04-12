typeset -ga precmd_functions
typeset -ga preexec_functions
autoload colors
colors
export AUTO_TITLE_SCREENS="NO"
set-title() {
    echo -e "\e]0;$*\007"
}
ssh() {
    set-title $*;
    /usr/bin/ssh -2 $*;
    set-title $HOST;
}
alias gs='git status'
alias gl='git log --oneline -n 10'
alias gd='git diff'
alias gbl='git branch --list --sort=-committerdate'
alias ga='git commit --amend --no-edit'
alias ges="code \`git status --porcelain | sed s/^...// | tr '\n' ' '\`"
alias ll='ls -lh'
export PROMPT="
%{$fg[red]%}(%D %*) ${CONTAINER_NAME:-container} (%m) <%?>
[%~] $program
%#%{$fg[default]%} "
export RPROMPT=
######################### zsh options ################################
setopt ALWAYS_TO_END           # Push that cursor on completions.
setopt AUTO_NAME_DIRS          # change directories  to variable names
setopt AUTO_PUSHD              # push directories on every cd
setopt NO_BEEP                 # self explanatory
######################### history options ############################
setopt EXTENDED_HISTORY        # store time in history
setopt HIST_EXPIRE_DUPS_FIRST  # unique events are more usefull to me
setopt HIST_VERIFY             # Make those history commands nice
setopt INC_APPEND_HISTORY      # immediatly insert history into history file
HISTSIZE=16000                 # spots for duplicates/uniques
SAVEHIST=15000                 # unique events guarenteed
HISTFILE=~/.history
setopt histignoredups          # ignore duplicates of the previous event
######################### completion #################################
# these are some (mostly) sane defaults, if you want your own settings, I
# recommend using compinstall to choose them.  See 'man zshcompsys' for more
# info about this stuff.
# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' use-compctl true
if [[ $IGNORE_APOLLO_1 != 'NO' ]]
then
  # Ignore /apollo_1 for directories.  That dir is an import directory
  zstyle ':completion:*' ignored-patterns '/apollo_1'
fi
autoload zmv
alias 'zcp=noglob zmv -W -C'
alias 'zln=noglob zmv -W -L'
alias 'zmv=noglob zmv -W -M'
# If you don't want compinit called here, place the line
# skip_global_compinit=1
# in your $ZDOTDIR/.zshenv or $ZDOTDIR/.zprofile
if [[ -z "$skip_global_compinit" ]]; then
  autoload -U compinit
  compinit
fi
# End of lines added by compinstall

######### NVM Begin #########
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use default --silent
######### NVM End #########

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=code

alias c='code'