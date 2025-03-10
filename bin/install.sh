#!/bin/sh

set -e

TLREPO=${CTAN_REPO:-http://mirror.ctan.org/systems/texlive/tlnet}
TLINST="install-tl-unx.tar.gz"
TLURL=$TLREPO/$TLINST
PRNAME="tinytex.profile"
PRURL="https://yihui.org/gh/tinytex/tools"
if [ $(uname) = 'Darwin' ]; then
  alias sedi="sed -i ''"
  [ -e $TLINST ] || curl -LO $TLURL
  [ -e $PRNAME ] || curl -LO $PRURL/$PRNAME
else
  alias sedi="sed -i"
  [ -e $TLINST ] || wget $TLURL
  [ -e $PRNAME ] || wget $PRURL/$PRNAME
  # ask `tlmgr path add` to add binaries to ~/bin instead of the default
  # /usr/local/bin unless this script is invoked with the argument '--admin'
  # (e.g., users want to make LaTeX binaries available system-wide), in which
  # case we personalize texmf variables
  if [ "$1" = '--admin' ]; then
    echo 'TEXMFCONFIG $HOME/.TinyTeX/texmf-config' >> $PRNAME
    echo 'TEXMFVAR $HOME/.TinyTeX/texmf-var' >> $PRNAME
  else
    mkdir -p $HOME/bin
    echo "tlpdbopt_sys_bin $HOME/bin" >> $PRNAME
  fi
fi

# no need to personalize texmf variables if not installed by admin
if [ "$1" != '--admin' ]; then
  echo 'TEXMFCONFIG $TEXMFSYSCONFIG' >> $PRNAME
  echo 'TEXMFVAR $TEXMFSYSVAR' >> $PRNAME
fi

tar -xzf $TLINST

mkdir texlive
cd texlive
TEXLIVE_INSTALL_ENV_NOCHECK=true TEXLIVE_INSTALL_NO_WELCOME=true ../install-tl-*/install-tl -no-gui -profile=../$PRNAME -repository $TLREPO
rm -r ../install-tl-*/ ../$PRNAME install-tl.log
rm -f install-tl

alias tlmgr='./bin/*/tlmgr'
rm -f bin/man bin/*/man

tlmgr option repository "$TLREPO"
tlmgr conf texmf max_print_line 10000

if [ "$3" != '' ]; then
  tlmgr option repository "$3"
  if [ "$4" != '' ]; then
    tlmgr --repository http://www.preining.info/tlgpg/ install tlgpg
  fi
  # test if the repository is accessible; if not, set the default CTAN repo
  tlmgr update --list || ./tlmgr option repository ctan
fi
tlmgr install amscls amsfonts amsmath atbegshi atveryend auxhook babel bibtex bigintcalc bitset booktabs cm ctablestack dehyph dvipdfmx dvips ec epstopdf-pkg etex etexcmds etoolbox euenc everyshi fancyvrb filehook firstaid float fontspec framed geometry gettitlestring glyphlist graphics graphics-cfg graphics-def helvetic hycolor hyperref hyph-utf8 iftex inconsolata infwarerr intcalc knuth-lib kvdefinekeys kvoptions kvsetkeys l3backend l3kernel l3packages latex latex-amsmath-dev latex-bin latex-fonts latex-tools-dev latexconfig latexmk letltxmacro lm lm-math ltxcmds lua-alt-getopt lua-uni-algos luahbtex lualatex-math lualibs luaotfload luatex luatexbase mdwtools metafont mfware natbib pdfescape pdftex pdftexcmds plain psnfss refcount rerunfilecheck selnolig stringenc tex tex-ini-files times tipa tools unicode-data unicode-math uniquecounter url xcolor xetex xetexconfig xkeyval xunicode zapfding 
