#!/bin/bash
#
# This script is used to build a tarball of a TeX Live portable installation.
#
# Tested on Linux and Darwin.
#
set -e

make_tempfile() {
  mktemp -t texlive.XXXXXX
}

PKGS_ADD="fontspec float eurosym tabto-ltx vntex"
PKGS_REMOVE="amsfonts koma-script"

REPO="http://ctan.mines-albi.fr"
INSTALLER_URL="$REPO/systems/texlive/tlnet/install-tl-unx.tar.gz"
PLATFORM=$(uname -m)-$(uname -s | tr A-Z a-z)
DESTDIR=$(make_tempfile)
PROFILE=$(make_tempfile)
INSTALLER_TARBALL=$(make_tempfile)
INSTALLER=$(make_tempfile)
PATCHLEVEL=$1
: ${PATCHLEVEL:=0}

# Prepare profile for install-tl script

cat > $PROFILE <<EOF
# texlive.profile written on $(date)
# It will NOT be updated and reflects only the
# installation profile at installation time.
selected_scheme scheme-custom
TEXDIR $DESTDIR
TEXMFCONFIG \$TEXMFSYSCONFIG
TEXMFHOME \$TEXMFLOCAL
TEXMFLOCAL $DESTDIR/texmf-local
TEXMFSYSCONFIG $DESTDIR/texmf-config
TEXMFSYSVAR $DESTDIR/texmf-var
TEXMFVAR /tmp

binary_${PLATFORM} 1

collection-basic 1
collection-latex 1
collection-latexrecommended 1
collection-xetex 1

in_place 0
option_adjustrepo 1
option_autobackup 1
option_backupdir tlpkg/backups
option_desktop_integration
option_doc 0
option_file_assocs 
option_fmt 1
option_letter
option_menu_integration 
option_path
option_post_code 1
option_src 0
option_sys_bin /usr/local/bin
option_sys_info /usr/local/share/info
option_sys_man /usr/local/share/man
option_w32_multi_user 1
option_write18_restricted 1
portable 1
EOF


# Cleanup, then fetch installer tarball, and deduct version from its contents

rm -rf $DESTDIR $INSTALLER
mkdir -p $INSTALLER
curl -L $INSTALLER_URL > $INSTALLER_TARBALL
BASE_VERSION=$(tar ztf $INSTALLER_TARBALL | head -1 | sed 's/[^0-9]//g')
VERSION=${BASE_VERSION}-p${PATCHLEVEL}
TARBALL=texlive-${VERSION}-${PLATFORM}.tar.gz

if test -e $TARBALL ; then
  echo "$TARBALL already exists. Increase patchlevel (pass it as \$1)"
  exit 1
fi

# Unpack and run the installer
tar -C $INSTALLER --strip-components=1 -zxf $INSTALLER_TARBALL
(cd $INSTALLER && ./install-tl -profile $PROFILE -repository $REPO/)

# Keep a copy of our profile
cp $PROFILE $DESTDIR/tlpkg/install.profile

# Add/remove custom packages
$DESTDIR/bin/$PLATFORM/tlmgr install $PKGS_ADD
$DESTDIR/bin/$PLATFORM/tlmgr remove --force $PKGS_REMOVE

tar -C $DESTDIR -cf -  . | gzip -9 -c > $TARBALL

echo "*********************"
echo "Install and packaging complete."
echo "Installer:    $INSTALLER"
echo "Distribution: $DESTDIR"
echo "Tarball:      $TARBALL"
exit 0
