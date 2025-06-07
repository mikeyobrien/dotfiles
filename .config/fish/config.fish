if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Fix locale for nix bash
set -x LC_ALL en_US.utf8
alias sdw='ssh driftwood'
alias gs='git status'
alias gdiff='git diff'
alias tl='tmux list-sessions'
alias c='claude --dangerously-skip-permissions'

# Manjaro proot aliases
alias manjaro="~/manjaro-login"
alias manjaro-run="proot-distro login manjaro --"
alias manjaro-home="proot-distro login manjaro --bind /data/data/com.termux/files/home:/home/termux"
alias manjaro-storage="proot-distro login manjaro --bind /data/data/com.termux/files/home/storage:/home/mobrienv/storage"
alias manjaro-here="proot-distro login manjaro --bind (pwd):/mnt/current"

# Function to bind mount custom paths
function manjaro-bind
    if test (count $argv) -lt 2
        echo "Usage: manjaro-bind /host/path /container/path [command]"
        return 1
    end
    set -l host_path $argv[1]
    set -l container_path $argv[2]
    set -e argv[1..2]
    proot-distro login manjaro --bind "$host_path:$container_path" -- $argv
end

# Run command in Manjaro with current directory mounted
function manjaro-exec
    proot-distro login manjaro --bind (pwd):/mnt/current -- $argv
end

# UV/uvx configuration for Termux
# Use a custom cache directory and enable symlinks for better performance
set -gx UV_CACHE_DIR "$HOME/uv-cache"
set -gx UV_LINK_MODE symlink
