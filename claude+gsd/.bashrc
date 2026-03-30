# OpenShell's connect defaults to bash — switch to zsh automatically
if [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
    exec zsh -l
fi
