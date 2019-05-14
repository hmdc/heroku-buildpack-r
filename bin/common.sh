error() {
  echo " !     $*" >&2
  exit 1
}

head() {
  echo ""
  echo "-----> $*"
}

info() {
  #echo "`date +\"%M:%S\"`  $*"
  echo "       $*"
}

warning() {
  tip=$1
  url=$2
  echo "WARNING: $tip" >> $warnings
  echo "${url:-https://github.com/lookfirst/heroku-buildpack-apache}" >> $warnings
  echo "" >> $warnings
}

protip() {
  echo
  echo "PRO TIP: $*" | indent
  echo "See https://github.com/lookfirst/heroku-buildpack-apache" | indent
  echo
}

build_failed() {
  head "Build failed"
  info "We're sorry this build is failing!"
  info "Please open an issue so we can help: https://github.com/lookfirst/heroku-buildpack-apache/issues"
}

file_contents() {
  if test -f $1; then
    echo "$(cat $1)"
  else
    echo ""
  fi
}

# sed -l basically makes sed replace and buffer through stdin to stdout
# so you get updates while the command runs and dont wait for the end
# e.g. npm install | indent
indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";; # mac/bsd sed: -l buffers on line boundaries
    *)      sed -u "$c";; # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
  esac
}

export_env_dir() {
  env_dir=$3
  whitelist_regex=${2:-''}
  blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
  if [ -d "$env_dir" ]; then
    for e in $(ls $env_dir); do
      echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
      export "$e=$(cat $env_dir/$e)"
      :
    done
  fi
}