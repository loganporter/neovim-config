#!/bin/sh
# $EDITOR for the resterm float (see lua/config/resterm.lua).
#
# resterm's `g e` opens the current request file in $EDITOR. Left to itself
# that spawns a *nested* nvim inside the float -- a second editor, with none of
# your LSP or session state, drawn inside a terminal inside the real editor.
# This shim hands the file to the nvim that launched resterm instead.
#
# resterm waits for $EDITOR to exit before re-reading the file, and Neovim has
# no --remote-wait (E5600: "Wait commands not yet implemented"), so the block
# is rebuilt here: config.resterm.edit() opens the file and creates $sentinel
# once the buffer is closed; this script polls for it.
#
# Neovim sets $NVIM to the parent's RPC socket for jobs it starts, so this only
# takes effect for a resterm launched from inside nvim; run from a plain shell
# it falls through to a normal editor.
if [ -z "$NVIM" ] || [ $# -eq 0 ]; then
  exec "${RESTERM_FALLBACK_EDITOR:-nvim}" "$@"
fi

file=$1
case $file in
  /*) ;;
  *) file="$(pwd)/$file" ;;
esac

sentinel="${TMPDIR:-/tmp}/resterm-edit-$$"
rm -f "$sentinel"

# Vimscript single-quoted strings escape ' by doubling it.
quote() { printf "'%s'" "$(printf '%s' "$1" | sed "s/'/''/g")"; }

nvim --server "$NVIM" --remote-expr \
  "luaeval(\"require('config.resterm').edit(_A[1], _A[2])\", [$(quote "$file"), $(quote "$sentinel")])" \
  >/dev/null 2>&1 || exit 1

# If $NVIM is a unix socket, its disappearance means the parent died and the
# sentinel is never coming.
watch_socket=0
[ -S "$NVIM" ] && watch_socket=1

while [ ! -e "$sentinel" ]; do
  if [ "$watch_socket" = 1 ] && [ ! -S "$NVIM" ]; then
    break
  fi
  sleep 0.2
done

rm -f "$sentinel"
