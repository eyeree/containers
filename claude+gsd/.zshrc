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
alias ll='ls -lh'
export PROMPT="
%{$fg[red]%}(%D %*) claude+gsd (%m) <%?>
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
zstyle ':completion:*' completer _expand _complete _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' use-compctl true
autoload zmv
alias 'zcp=noglob zmv -W -C'
alias 'zln=noglob zmv -W -L'
alias 'zmv=noglob zmv -W -M'
if [[ -z "$skip_global_compinit" ]]; then
  autoload -U compinit
  compinit
fi

######### NVM Begin #########
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm use default --silent
######### NVM End #########

export PATH="$HOME/.local/bin:$PATH"
