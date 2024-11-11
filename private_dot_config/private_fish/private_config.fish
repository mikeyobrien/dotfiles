if status is-interactive
    # Commands to run in interactive sessions can go here
end


# git functions
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gst='git stash'
alias gsw='git switch'
alias grb='git rebase'
alias grs='git reset'
alias gm='git merge'
alias gf='git fetch'
alias gcl='git clone'
alias grm='git remote'
alias grv='git remote -v'
alias glog='git log --oneline --decorate --graph'
alias gnuke='git reset --hard && git clean -fd'


alias cmdiff='chezmoi diff'
alias cmcd='cd $(chezmoi source-path)'

function cme
	chezmoi edit $argv
end

function cma
	chezmoi add $argv
end

