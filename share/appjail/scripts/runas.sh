#!/bin/sh

CONFIG="%%PREFIX%%/share/appjail/files/config.conf"

. "${CONFIG}"

if ! which -s "${RUNAS}"; then
	. "${LIBDIR}/load"
	lib_load "${LIBDIR}/sysexits"
	lib_load "${LIBDIR}/log"

	lib_err ${EX_UNAVAILABLE} -- "${RUNAS}: program not found."
fi

CMD="$1"; shift

if [ -z "${CMD}" ]; then
	echo "usage: runas.sh cmd args..."
	exit 1
fi

"${RUNAS}" "${CMD}" "$@"
