#!/bin/sh
#
# Copyright (c) 2023, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

main()
{
	local value="$1" type="${2:-makejail}"

	if [ -z "${value}" ]; then
		usage
		exit 64 # EX_USAGE
	fi

	if [ "${type}" = "makejail" ]; then
		escape_makejail "${value}"
	elif [ "${type}" = "internal" ]; then
		escape_internal "${value}"
	else
		usage
		exit 64 # EX_USAGE
	fi
}

escape_makejail()
{
	local escape_harmful_regex='(\$\(|["`\])'
	local escape_harmful_prefix='\\'

	local escape_var_regex='\\(\$[^(])'

	printf "%s\n" "${value}" | \
		sed -E \
		-e "s/${escape_harmful_regex}/${escape_harmful_prefix}\1/g" \
		-e "s/${escape_var_regex}/\1/g"
}

escape_internal()
{
	# Harmful characters.

	local escape_regex='\$\(|["`\]'
	local escape_prefix='\\\\\\'

	value=`printf "%s" "${value}" | sed -Ee "s/(${escape_regex})/${escape_prefix}\\1/g"`

	if printf "%s" "${value}" | grep -qEe '\\\\\\\$'; then
		# Escape \$.

		escape_regex='\\(\$[^(])'

		value=`printf "%s" "${value}" | sed -Ee "s/${escape_regex}/\1/g"`
	else
		# Escape $.

		escape_regex='\$[^(]'
		escape_prefix='\\'

		value=`printf "%s" "${value}" | sed -Ee "s/(${escape_regex})/${escape_prefix}\\1/g"`
	fi

	printf "%s\n" "${value}"
}

usage()
{
	echo "usage: escape-env-val.sh value [[makejail|internal]]"
}

main "$@"
