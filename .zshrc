export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git vi-mode z)

# Keep the system PATH and add to it; typeset -U drops duplicates.
typeset -U path
path=(~/.local/bin ~/.rbenv/plugins/ruby-build/bin $path)

# Completion directories must be on fpath before oh-my-zsh runs compinit.
fpath=(~/.local/share/zsh/site-functions $fpath)  # sentry, copilot

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

source ~/.aliases

eval "$(rbenv init - --no-rehash zsh)"

# nvm costs ~0.5 s per shell: put the default Node on PATH directly and load
# nvm itself only when it's called.
export NVM_DIR="$HOME/.nvm"
path=("$NVM_DIR"/versions/node/v$(<"$NVM_DIR/alias/default")*/bin(Nn[-1]) $path)
nvm() {
  unfunction nvm
  source "$NVM_DIR/nvm.sh"
  source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# Machine- and work-specific setup that stays out of this public repo.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

[[ -f ~/.config/agent-sandbox/sandvault.zsh ]] && source ~/.config/agent-sandbox/sandvault.zsh
