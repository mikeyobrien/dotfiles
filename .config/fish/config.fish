if status is-interactive
    # Commands to run in interactive sessions can go here
end
set -gx ATUIN_SESSION (atuin uuid)
set --erase ATUIN_HISTORY_ID

function _atuin_preexec --on-event fish_preexec
    if not test -n "$fish_private_mode"
        set -g ATUIN_HISTORY_ID (atuin history start -- "$argv[1]")
    end
end

function _atuin_postexec --on-event fish_postexec
    set -l s $status

    if test -n "$ATUIN_HISTORY_ID"
        ATUIN_LOG=error atuin history end --exit $s -- $ATUIN_HISTORY_ID &>/dev/null &
        disown
    end

    set --erase ATUIN_HISTORY_ID
end

function _atuin_search
    set -l keymap_mode
    switch $fish_key_bindings
        case fish_vi_key_bindings
            switch $fish_bind_mode
                case default
                    set keymap_mode vim-normal
                case insert
                    set keymap_mode vim-insert
            end
        case '*'
            set keymap_mode emacs
    end

    # In fish 3.4 and above we can use `"$(some command)"` to keep multiple lines separate;
    # but to support fish 3.3 we need to use `(some command | string collect)`.
    # https://fishshell.com/docs/current/relnotes.html#id24 (fish 3.4 "Notable improvements and fixes")
    set -l ATUIN_H (ATUIN_SHELL_FISH=t ATUIN_LOG=error ATUIN_QUERY=(commandline -b) atuin search --keymap-mode=$keymap_mode $argv -i 3>&1 1>&2 2>&3 | string collect)

    if test -n "$ATUIN_H"
        if string match --quiet '__atuin_accept__:*' "$ATUIN_H"
            set -l ATUIN_HIST (string replace "__atuin_accept__:" "" -- "$ATUIN_H" | string collect)
            commandline -r "$ATUIN_HIST"
            commandline -f repaint
            commandline -f execute
            return
        else
            commandline -r "$ATUIN_H"
        end
    end

    commandline -f repaint
end

function _atuin_bind_up
    # Fallback to fish's builtin up-or-search if we're in search or paging mode
    if commandline --search-mode; or commandline --paging-mode
        up-or-search
        return
    end

    # Only invoke atuin if we're on the top line of the command
    set -l lineno (commandline --line)

    switch $lineno
        case 1
            _atuin_search --shell-up-key-binding
        case '*'
            up-or-search
    end
end

bind \cr _atuin_search
bind -k up _atuin_bind_up
bind \eOA _atuin_bind_up
bind \e\[A _atuin_bind_up
if bind -M insert >/dev/null 2>&1
    bind -M insert \cr _atuin_search
    bind -M insert -k up _atuin_bind_up
    bind -M insert \eOA _atuin_bind_up
    bind -M insert \e\[A _atuin_bind_up
end


alias sdw='ssh driftwood'
alias gs='git status'
alias gdiff='git diff'
alias tl='tmux list-sessions'

fish_add_path (go env GOPATH)/bin
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
