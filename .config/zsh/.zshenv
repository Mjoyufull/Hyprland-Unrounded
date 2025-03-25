## Environment variables
if command -v nvim >/dev/null 2>&1; then
  export EDITOR='nvim'
elif command -v vim >/dev/null 2>&1; then
  export EDITOR='vim'
else
  export EDITOR='vi'
fi

export PAGER='less'

# I'll put it here I guess
typeset -U path
path=(~/bin $path)

