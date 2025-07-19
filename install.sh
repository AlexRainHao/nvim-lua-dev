#!/bin/bash

BASE_HOME=$(
    cd $(dirname $0)
    pwd
)

function echoerr() {
    echo -e "\033[0;31m$@ \033[0m"
    exit 1
}

function echoinfo() {
    echo -e "\033[0;32m$@ \033[0m"
}

function echowarn() {
    echo -e "\033[1;33m$@ \033[0m"
}

function install_neovim() {
  _version="v0.11.0"

  if printf '%s\n%s\n' "${_version#v}" "0.10.4" | sort -VC; then
    curl -s -L https://github.com/neovim/neovim/releases/download/${_version}/nvim-linux64.tar.gz | tar zxvf -
  else
    curl -s -L https://github.com/neovim/neovim/releases/download/${_version}/nvim-linux-x86_64.tar.gz | tar zxvf -
  fi

  echoinfo "prepare downloading nvim $_version ..."


  if [[ $? != 0 ]]; then
    echoerr "download nvim ${_version} failed"
  fi
}


function install_lazygit() {
  _version="0.34"

  echoinfo "prepare downloading lazygit $_version ..."

  mkdir -p lazygit && \
    curl -s -L https://github.com/jesseduffield/lazygit/releases/download/v${_version}/lazygit_${_version}_Linux_x86_64.tar.gz \
    | tar zxvf - -C lazygit

  if [[ $? != 0 ]]; then
    echoerr "download lazygit ${_version} failed"
  fi
}

function install_fd() {
  echoinfo "prepare downloading fd ..."

  curl -s -L https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-musl_10.2.0_amd64.deb -o fd.deb && \
    dpkg -i fd.deb
  
  if [[ $? != 0 ]]; then
    echoerr "download fd failed"
  fi
}

function install_ripgrep() {
  echoinfo "prepare downloading ripgrep ..."

  curl -s -L https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb -o ripgrep.deb && \
    dpkg -i ripgrep.deb
  
  if [[ $? != 0 ]]; then
    echoerr "download ripgrep failed"
  fi
}

function install_batcat() {
  echoinfo "prepare downloading batcat ..."
  apt install -y bat || echoerr "download batcat failed"
}

function install_fzf() {
  echoinfo "prepare downloading fzf"

  rm -rf ~/.fzf && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install || echoerr "download fzf failed"
}

function install_yazi() {
  git clone https://github.com/sxyazi/yazi.git && \
    cd yazi && \
    cargo build --release --locked && \
    mv target/release/yazi target/release/ya /usr/local/bin/
  
  if [[ $? != 0 ]]; then
    echoerr "download and build yazi failed"
  else
    rm -rf yazi
  fi

  apt install -y ffmpeg 7zip jq poppler-utils

  git clone https://github.com/linebender/resvg.git && \
      cd resvg && cargo build --release --locked && \
      mv target/release/resvg /usr/local/bin

  if [[ $? != 0 ]]; then
      echowarn "download and build  `resvg` failed"
  else
      rm -rf resvg
  fi

  # TODO: test `xclip` for linux-based clipboard support
}

function source_() {
  cd $BASE_HOME
  
  nvim_path=$(find . -maxdepth 1 -name 'nvim*' -type d | xargs realpath)/bin

  lazygit_path=$BASE_HOME/lazygit

  cat >> ~/.bashrc<< EOF
export PATH='$PATH:${nvim_path}:${lazygit_path}'
alias bat='batcat'
alias lg='lazygit'
EOF

  cat >> ~/.bashrc<< 'EOF'
# ===========================
# FZF
# ===========================
export FZF_COMPLETION_TRIGGER="\\"
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git --exclude node_modules"
export FZF_DEFAULT_OPTS="--no-mouse --height 70% -1 --reverse --multi --inline-info --preview='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (batcat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -300'"
EOF

  cat >> ~/.bashrc<< EOF
# ===========================
# yazi
# ===========================
export EDITOR=nvim
alias ya='yazi'
EOF

  source ~/.bashrc
}

function install() {
  echoinfo "prepare install packages..."

  if [[ $# == 0 ]]; then
    install_neovim && \
    install_lazygit && \
    install_fd && \
    install_ripgrep && \
    install_batcat && \
    install_fzf && \
    install_yazi
  else
    while [[ $# -gt 0 ]]; do
      case $1 in
        "nvim")
          install_neovim
          shift
          ;;
        "lg")
          install_lazygit
          shift
          ;;
        "fd")
          install_fd
          shift
          ;;
        "rp")
          install_ripgrep
          shift
          ;;
        "bat")
          install_batcat
          shift
          ;;
        "fzf")
          install_fzf
          shift
          ;;
        "yazi")
          install_yazi
          shift
          ;;
        *)
          echowarn "invalid argument $1"
          shift
          ;;
      esac
    done
  fi
}

function run() {
  if [[ $# -eq 0 ]]; then
    echowarn "argument of 'install' or 'source' supported"
    return
  fi

  case $1 in
    "install")
      shift
      install $@
      ;;
    "source")
      shift
      source_
      ;;
    *)
      echoerr "invalid argument $@"
      ;;
  esac
}


cd $BASE_HOME && run $@ && cd -
