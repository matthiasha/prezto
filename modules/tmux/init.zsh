#
# Defines tmux aliases and provides for auto launching it at start-up.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Colin Hebert <hebert.colin@gmail.com>
#   Georges Discry <georges@discry.be>
#   Xavier Cambar <xcambar@gmail.com>
#

# Return if requirements are not found.
if (( ! $+commands[tmux] )); then
  return 1
fi

# Ensure that tmux server is started.
tmux start-server

tmux_session='prezto'

if ! tmux has-session -t "$tmux_session" 2> /dev/null; then
  # Disable the destruction of unattached sessions globally.
  tmux set-option -g destroy-unattached off &> /dev/null

  # Create a new session.
  tmux new-session -d -s "$tmux_session"

  # Disable the destruction of the new, unattached session.
  tmux set-option -t "$tmux_session" destroy-unattached off &> /dev/null

  # Enable the destruction of unattached sessions globally to prevent
  # an abundance of open, detached sessions.
  tmux set-option -g destroy-unattached on &> /dev/null
fi

# Set options globally
tmux set -g mode-mouse on &> /dev/null
tmux set -g history-limit 100000 &> /dev/null
tmux set -g mouse-select-pane on &> /dev/null
tmux set -g mouse-resize-pane on &> /dev/null
tmux set -g mouse-select-window on &> /dev/null

#
# Auto Start
#

if ([[ "$TERM_PROGRAM" = 'iTerm.app' ]] && \
  zstyle -t ':prezto:module:tmux:iterm' integrate \
); then
  _tmux_iterm_integration='-CC'
fi

if [[ -z "$TMUX" && -z "$EMACS" && -z "$VIM" ]] && ( \
  ( [[ -n "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' remote ) ||
  ( [[ -z "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' local ) \
); then
  tmux start-server

  # Create a 'prezto' session if no session has been defined in tmux.conf.
  if ! tmux has-session 2> /dev/null; then
    tmux_session='prezto'
    tmux \
      new-session -d -s "$tmux_session" \; \
      set-option -t "$tmux_session" destroy-unattached off &> /dev/null
  fi

  # Attach to the 'prezto' session or to the last session used.
  exec tmux $_tmux_iterm_integration attach-session
fi

#
# Aliases
#

alias tmuxa="tmux $_tmux_iterm_integration new-session -A"
alias tmuxl='tmux list-sessions'
