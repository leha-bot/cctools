build_binutils() {
    PKG=binutils
    PKG_VERSION=$binutils_version
    PKG_DESC="GNU assembler, linker and binary utilities"
    O_DIR=$SRC_PREFIX/$PKG/${PKG}-${PKG_VERSION}
    S_DIR=$src_dir/${PKG}-${PKG_VERSION}
    B_DIR=$build_dir/binutils

    c_tag $PKG && return

    banner "Build $PKG"

    pushd .

    copysrc $O_DIR $S_DIR

    cd $S_DIR
    patch -p1 < $patch_dir/${PKG}-${PKG_VERSION}.patch

    mkdir -p $B_DIR
    cd $B_DIR

    $S_DIR/configure \
	--target=$TARGET_ARCH \
	--host=$TARGET_ARCH \
	--prefix=$TARGET_DIR \
	--with-sysroot=$SYSROOT \
	--disable-werror || error "configure"


    $MAKE $MAKEARGS || error "make $MAKEARGS"

    $MAKE install prefix=${TMPINST_DIR}/${PKG}/cctools || error "package install"

    $TARGET_ARCH-strip ${TMPINST_DIR}/${PKG}/cctools/bin/*

    ln -sf ld ${TMPINST_DIR}/${PKG}/cctools/bin/ld.bfd
    #cd ${TMPINST_DIR}/${PKG}/cctools/${TARGET_ARCH}/bin
    #for f in * ; do
    #	ln -sf ../../bin/$f $f
    #done

    rm -rf ${TMPINST_DIR}/${PKG}/cctools/${TARGET_ARCH}/bin
    rm -rf ${TMPINST_DIR}/${PKG}/cctools/include
    rm -rf ${TMPINST_DIR}/${PKG}/cctools/share
    rm -f ${TMPINST_DIR}/${PKG}/cctools/lib/libbfd.*a
    rm -f ${TMPINST_DIR}/${PKG}/cctools/lib/libiberty.a
    rm -f ${TMPINST_DIR}/${PKG}/cctools/lib/libopcodes.*a

    local filename="${PKG}_${PKG_VERSION}_${PKG_ARCH}.zip"
    build_package_desc ${TMPINST_DIR}/${PKG} $filename ${PKG} $PKG_VERSION $PKG_ARCH "$PKG_DESC"
    cd ${TMPINST_DIR}/${PKG}
    zip -r9y ../$filename cctools pkgdesc

    popd
    s_tag $PKG
}
