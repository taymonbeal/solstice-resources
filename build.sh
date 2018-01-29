#!/bin/bash
set -eu
set -o pipefail

CACHED_AUX_DIR="/opt/build/cache/aux"
AUX_DIR="$PWD/aux"

if [[ -d $CACHED_AUX_DIR ]]; then
  rm -rf $AUX_DIR
  mv $CACHED_AUX_DIR $AUX_DIR
else
  mkdir -p $AUX_DIR
fi

if [[ ! -d $AUX_DIR/freepats ]]; then
  curl https://freepats.zenvoid.org/freepats-20060219.tar.xz | tar xJC $AUX_DIR
fi

if [[ ! -f $AUX_DIR/bin/gs ]]; then
  mkdir -p $AUX_DIR/bin
  curl -L \
       https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs922/ghostscript-9.22-linux-x86_64.tgz |
    tar xzO ghostscript-9.22-linux-x86_64/gs-922-linux-x86_64 >$AUX_DIR/bin/gs
  chmod +x $AUX_DIR/bin/gs
fi

if [[ ! -f $AUX_DIR/bin/lame ]]; then
  lame_src_dir=$(mktemp -d)
  curl -L \
       https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz/download |
      tar xzC $lame_src_dir
  (
      cd $lame_src_dir/lame-3.100
      ./configure --prefix=$AUX_DIR
      make install
  )
fi

if [[ ! -d $AUX_DIR/lilypond ]]; then
  lilypond_installer=$(mktemp)
  wget -O $lilypond_installer \
       https://download.linuxaudio.org/lilypond/binaries/linux-64/lilypond-2.18.2-1.linux-64.sh
  sh $lilypond_installer --batch --prefix=$AUX_DIR
fi

if [[ ! -f $AUX_DIR/bin/timidity ]]; then
  timidity_src_dir=$(mktemp -d)
  curl -L \
       https://sourceforge.net/projects/timidity/files/TiMidity%2B%2B/TiMidity%2B%2B-2.14.0/TiMidity%2B%2B-2.14.0.tar.xz/download |
      tar xJC $timidity_src_dir
  (
      cd $timidity_src_dir/TiMidity++-2.14.0
      ./configure --prefix=$AUX_DIR
      make install
  )
  mkdir -p $AUX_DIR/share/timidity
  (
      echo "dir $AUX_DIR/freepats"
      echo "source $AUX_DIR/freepats/freepats.cfg"
  ) >$AUX_DIR/share/timidity/timidity.cfg
fi

PATH="$AUX_DIR/bin:$AUX_DIR/lilypond/usr/bin:$PATH" make all

mv $AUX_DIR $CACHED_AUX_DIR
