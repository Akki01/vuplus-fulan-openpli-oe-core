FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://cryptography-1.2.2-openssl-1.0.2g-mem_buf.patch \
"
