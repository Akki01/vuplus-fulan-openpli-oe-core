
# Remove acl, cups etc. support.
PACKAGECONFIG = "${@base_contains('DISTRO_FEATURES', 'pam', 'pam', '', d)} \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', '${SYSVINITTYPE}', '', d)} \
                 ${@base_contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
                 ${@base_contains('DISTRO_FEATURES', 'zeroconf', 'zeroconf', '', d)} \
                 aio \
                "

EXTRA_OECONF += " \
                 --without-cluster-support \
                 --without-profiling-data \
                 --with-sockets-dir=${localstatedir}/run \
                 --with-logfilebase=${localstatedir}/log \
                 --nopyc \
                "

EXTRA_OECONF_remove = " \
                       --with-cluster-support \
                       --with-profiling-data \
                       --with-sockets-dir=${localstatedir}/run/samba \
                      "

# Remove unused, add own config, init script
SRC_URI += " \
           file://smb.conf \
           file://samba.sh \
           "

FILES_${PN}-base += "${sysconfdir}/init.d/samba.sh"

# Get the cross-answers from cross-execute
CROSS_METHOD = "exec"

# Creates an empty cross-answers file to fix building error
WAF_CROSS_ANSWERS_PATH = "${S}/patches"

do_configure_prepend () {
    echo '' >> ${WAF_CROSS_ANSWERS_PATH}/cross-answers-${TARGET_ARCH}.txt
}

do_install_prepend() {
	install -d ${D}/run/samba
}

do_install_append() {
	rm -fR ${D}/var
	rm -fR ${D}/run
	rm -fR ${D}${bindir}
	rm -fR ${D}${libdir}/tmpfiles.d
	rm -fR ${D}${sysconfdir}/sysconfig
	install -d ${D}/var/lib/samba/private
	install -d ${D}${sysconfdir}/samba
	install -m 644 ${WORKDIR}/smb.conf ${D}${sysconfdir}/samba
	install -d ${D}${sysconfdir}/init.d
	install -m 755 ${WORKDIR}/samba.sh ${D}${sysconfdir}/init.d
}

inherit update-rc.d
INITSCRIPT_PACKAGES = "${PN}-base"
INITSCRIPT_NAME_${PN}-base = "samba.sh"
INITSCRIPT_PARAMS_${PN}-base = "defaults"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# workaround to get rid of perl dependency
RDEPENDS_${PN}_remove = "perl"