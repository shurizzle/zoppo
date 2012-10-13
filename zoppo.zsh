# Profiling {{{
if [[ "$1" == 'profile' ]]; then
  setopt prompt_subst
  PS4='+$(date +"%H:%M:%S.%N") %N:%i> '
  exec 3>&2 2>"/tmp/zoppo.profile.$(date +%Y%m%d@%H%M%S)"
  setopt xtrace prompt_subst
fi
# }}}

# Minimum Version Check {{{
if ! autoload -Uz is-at-least || ! is-at-least '4.3.10'; then
  print "prezto: old shell detected, minimum required: 4.3.10" >&2
  return 1
fi
# }}}

# Load Libraries {{{
typeset -ga fpath
fpath=("${0:h:a}/lib/functions" $fpath)

LIBPATH="${0:h:a}/lib"
function {
  local zfunction

  setopt LOCAL_OPTIONS EXTENDED_GLOB
  for zfunction ("$LIBPATH"/functions/^([._]|README)*(.N:t))
    autoload -Uz -- "$zfunction"
}
unset LIBPATH

source "${0:h:a}/lib/init.zsh"
# }}}

# Default Paths {{{
zdefault ':zoppo:path' base "${0:h:a}"
zdefault ':zoppo:path' cache "${0:h:a}/cache"
zdefault ':zoppo:path' plugins "${0:h:a}/plugins"
zdefault ':zoppo:path' prompts "${0:h:a}/prompts"
# }}}

if [[ -s "${ZDOTDIR:-$HOME}/.zopporc" ]]; then
  source "${ZDOTDIR:-$HOME}/.zopporc"
fi

# create cache directory unless present
if [[ ! -d $(path:cache) ]]; then
  mkdir -p "$(path:cache)"
fi

# disable all coloring if the terminal is dumb
if terminal:is-dumb; then
  zstyle ':zoppo:*:*' color 'no'
  zstyle ':zoppo' prompt 'off'
fi

# Environment Options {{{
function {
  local -a zoptions
  local option

  zdefault -a ':zoppo' options zoptions \
    'brace-ccl' 'rc-quotes' 'no-mail-warning' 'long-list-jobs' 'auto-resume' 'notify' \
    'no-bg-nice' 'no-hup' 'no-check-jobs'

  for option ("$zoptions[@]"); do
    if [[ "$option" =~ "^no-" ]]; then
      if ! options:disable "${option#no-}"; then
        print "zoppo: ${option#no-} not found: could not disable"
      fi
    else
      if ! options:enable "$option"; then
        print "zoppo: $option not found: could not enable"
      fi
    fi
  done
}
# }}}

# Initialize Prompts {{{
typeset -a prompts_path
zstyle -a ':zoppo:path' prompts prompts_path
(( $#prompts_path > 0 )) && functions:add "${prompts_path[@]}"
unset prompts_path
functions:autoload promptinit && promptinit
typeset -a zoppo_prompt
zdefault -a ':zoppo' prompt zoppo_prompt 'off'
prompt "$zoppo_prompt[@]"
unset zoppo_prompt
# }}}

# Load Modules {{{
zstyle -a ':zoppo:load' modules zmodules
for zmodule ("$zmodules[@]") zmodload "zsh/${(z)module}"
unset zmodule{,s}
# }}}

# Autoload Functions {{{
zstyle -a ':zoppo:load' functions zfunctions
(( $#zfunctions > 0 )) && functions:autoload "$zfunctions[@]"
unset zfunctions
# }}}

# Load Plugins {{{
zstyle -a ':zoppo:load' plugins zplugins
(( $#zplugins > 0 )) && zplugload "$zplugins[@]"
unset zplugins
# }}}

hooks:call zoppo_postinit

# Profiling {{{
if [[ "$1" == 'profile' ]]; then
  unsetopt xtrace
  exec 2>&3 3>&-
  unset PS4
fi
# }}}

# vim: ft=zsh sts=2 ts=2 sw=2 et fdm=marker fmr={{{,}}}
