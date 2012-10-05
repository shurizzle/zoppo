if ! is-callable realpath; then
  function realpath {
    [ $# = 0 ] && {
      print "USAGE: $0 path [path ...]"
      return 1
    }

    for f ("$@")
      print ${f}(:A)
  }
fi

# vim: ft=zsh sts=2 ts=2 sw=2 et fdm=marker fmr={{{,}}}
