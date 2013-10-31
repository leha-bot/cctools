build_file() {
    PKG=file
    PKG_VERSION=5.15
    PKG_URL="ftp://ftp.astron.com/pub/file/${PKG}-${PKG_VERSION}.tar.gz"
    PKG_DESC="Determines file type using "magic" numbers"
    PKG_DEPS=""
    O_FILE=$SRC_PREFIX/${PKG}/${PKG}-${PKG_VERSION}.tar.gz
    S_DIR=$src_dir/${PKG}-${PKG_VERSION}
    B_DIR=$build_dir/${PKG}

    c_tag $PKG && return

    pushd .

    banner "Build $PKG"

    #download $PKG_URL $O_FILE

    #unpack $src_dir $O_FILE

    #patchsrc $S_DIR $PKG $PKG_VERSION

    mkdir -p $B_DIR
    cd $B_DIR

    # Configure here

    ${S_DIR}/configure	\
	--host=${TARGET_ARCH} \
        --prefix=$TARGET_INST_DIR \
	CPPFLAGS="-I${TMPINST_DIR}/include" \
	LDFLAGS="-L${TMPINST_DIR}/lib" \
			|| error "Configure $PKG."

    $MAKE $MAKEARGS || error "make $MAKEARGS"

    #$MAKE install || error "make install"

    $MAKE install prefix=${TMPINST_DIR}/${PKG}/cctools || error "package install"

    $TARGET_ARCH-strip ${TMPINST_DIR}/${PKG}/cctools/bin/*
    $TARGET_ARCH-strip ${TMPINST_DIR}/${PKG}/cctools/lib/*.so*
    rm -rf ${TMPINST_DIR}/${PKG}/cctools/include
    rm -rf ${TMPINST_DIR}/${PKG}/cctools/lib/*.la
    rm -rf ${TMPINST_DIR}/${PKG}/cctools/share/man

    local filename="${PKG}_${PKG_VERSION}_${PKG_ARCH}.zip"
    build_package_desc ${TMPINST_DIR}/${PKG} $filename $PKG $PKG_VERSION $PKG_ARCH "$PKG_DESC" "$PKG_DEPS"
    cd ${TMPINST_DIR}/${PKG}
    zip -r9y ${REPO_DIR}/$filename cctools pkgdesc

    popd
    s_tag $PKG
}