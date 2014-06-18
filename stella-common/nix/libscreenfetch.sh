# from https://github.com/KittyKatt/screenFetch

# Distro Detection - Begin
detectdistro () {
	if [[ -z $distro ]]; then
		distro="Unknown"

		# LSB Release Check
		if type -p lsb_release >/dev/null 2>&1; then
			# read distro_detect distro_release distro_codename <<< $(lsb_release -sirc)
			distro_detect=( $(lsb_release -sirc) )
			if [[ ${#distro_detect[@]} -eq 3 ]]; then
				distro_codename=${distro_detect[2]}
				distro_release=${distro_detect[1]}
				distro_detect=${distro_detect[0]}
			else
				for ((i=0; i<${#distro_detect[@]}; i++)); do
					if [[ ${distro_detect[$i]} =~ ^[[:digit:]]+((.[[:digit:]]+|[[:digit:]]+|)+)$ ]]; then
						distro_release=${distro_detect[$i]}
						distro_codename=${distro_detect[@]:$(($i+1)):${#distro_detect[@]}+1}
						distro_detect=${distro_detect[@]:0:${i}}
						break 1
					elif [[ ${distro_detect[$i]} =~ [Nn]/[Aa] || ${distro_detect[$i]} == "rolling" ]]; then
						distro_release=${distro_detect[$i]}
						distro_codename=${distro_detect[@]:$(($i+1)):${#distro_detect[@]}+1}
						distro_detect=${distro_detect[@]:0:${i}}
						break 1
					fi
				done
			fi

			if [[ "${distro_detect}" == "archlinux" || "${distro_detect}" == "Arch Linux" || "${distro_detect}" == "arch" || "${distro_detect}" == "Arch" || "${distro_detect}" == "archarm" ]]; then
				distro="Arch Linux"
				distro_release="n/a"
				if grep -q 'antergos' /etc/os-release; then
					distro="Antergos"
					distro_release="n/a"
				fi
			elif [[ "${distro_detect}" == "Chakra" ]]; then
				distro="Chakra"
				distro_release=null
			elif [[ "${distro_detect}" == "CentOS" ]]; then
				distro="CentOS"
			elif [[ "${distro_detect}" == "Debian" ]]; then
				if [[ -f /etc/crunchbang-lsb-release || -f /etc/lsb-release-crunchbang ]]; then
					distro="CrunchBang"
					distro_release=$(awk -F'=' '/^DISTRIB_RELEASE=/ {print $2}' /etc/lsb-release-crunchbang)
					distro_codename=$(awk -F'=' '/^DISTRIB_DESCRIPTION=/ {print $2}' /etc/lsb-release-crunchbang)
				elif [[ -f /etc/os-release ]]; then
					if [[ "$(cat /etc/os-release)" =~ "Raspbian" ]]; then
						distro="Raspbian"
						distro_release=$(awk -F'=' '/^PRETTY_NAME=/ {print $2}' /etc/os-release)
					else
						distro="Debian"
					fi
				else
					distro="Debian"
				fi
			elif [[ "${distro_detect}" == "elementary" || "${distro_detect}" == "elementary OS" ]]; then
				distro="elementary OS"
			elif [[ "${distro_detect}" == "Fedora" ]]; then
				distro="Fedora"
			elif [[ "${distro_detect}" == "frugalware" ]]; then
				distro="Frugalware"
				distro_codename=null
				distro_release=null
			elif [[ "${distro_detect}" == "Fuduntu" ]]; then
				distro="Fuduntu"
				distro_codename=null
			elif [[ "${distro_detect}" == "Gentoo" ]]; then
				if [[ "$(lsb_release -sd)" =~ "Funtoo" ]]; then
					distro="Funtoo"
				else
					distro="Gentoo"
				fi
			elif [[ "${distro_detect}" == "Jiyuu Linux" ]]; then
				 distro="Jiyuu Linux"
			elif [[ "${distro_detect}" == "LinuxDeepin" ]]; then
				distro="LinuxDeepin"
				distro_codename=null
			elif [[ "${distro_detect}" == "Debian Kali Linux" ]]; then
				 distro="Kali Linux"
			elif [[ "${distro_detect}" == "Mageia" ]]; then
				distro="Mageia"
			elif [[ "$distro_detect" == "MandrivaLinux" ]]; then
				distro="Mandriva"
				if [[ "${distro_codename}" == "turtle" ]]; then
					distro="Mandriva-${distro_release}"
					distro_codename=null
				elif [[ "${distro_codename}" == "Henry_Farman" ]]; then
					distro="Mandriva-${distro_release}"
					distro_codename=null
				elif [[ "${distro_codename}" == "Farman" ]]; then
					distro="Mandriva-${distro_release}"
					distro_codename=null
				elif [[ "${distro_codename}" == "Adelie" ]]; then
					distro="Mandriva-${distro_release}"
					distro_codename=null
				elif [[ "${distro_codename}" == "pauillac" ]]; then
					distro="Mandriva-${distro_release}"
					distro_codename=null
				fi
			elif [[ "${distro_detect}" == "ManjaroLinux" ]]; then
				distro="Manjaro"
			elif [[ "${distro_detect}" == "LinuxMint" ]]; then
				distro="Mint"
				if [[ "${distro_codename}" == "debian" ]]; then
					distro="LMDE"
					distro_codename="n/a"
					distro_release="n/a"
				fi
			elif [[ "${distro_detect}" == "SUSE LINUX" || "${distro_detect}" == "openSUSE project" ]]; then
				distro="openSUSE"
			elif [[ "${distro_detect}" == "Parabola GNU/Linux-libre" || "${distro_detect}" == "Parabola" ]]; then
				distro="Parabola GNU/Linux-libre"
				distro_codename="n/a"
				distro_release="n/a"
			elif [[ "${distro_detect}" == "Peppermint" ]]; then
				distro="Peppermint"
				distro_codename=null
			elif [[ "${distro_detect}" == "CentOS" || "${distro_detect}" =~ "RedHatEnterprise" ]]; then
				distro="Red Hat Enterprise Linux"
			elif [[ "${distro_detect}" == "Sabayon" ]]; then
				distro="Sabayon"
			elif [[ "${distro_detect}" == "SolusOS" ]]; then
				distro="SolusOS"
			elif [[ "${distro_detect}" == "Trisquel" ]]; then
				distro="Trisquel"
			elif [[ "${distro_detect}" == "Ubuntu" ]]; then
				distro="Ubuntu"
			elif [[ "${distro_detect}" == "Viperr" ]]; then
				distro="Viperr"
				distro_codename=null
			fi
			if [[ -n ${distro_release} && ${distro_release} != "n/a" ]]; then distro_more="$distro_release"; fi
			if [[ -n ${distro_codename} && ${distro_codename} != "n/a" ]]; then distro_more="$distro_more $distro_codename"; fi
			if [[ -n ${distro_more} ]]; then
				distro_more="${distro} ${distro_more}"
			fi
		fi

		# Existing File Check
		if [ "$distro" == "Unknown" ]; then
			if [ $(uname -o 2>/dev/null) ]; then
				if [ `uname -o` == "Cygwin" ]; then distro="Cygwin"; fake_distro="${distro}"; fi
			fi
			if [ -f /etc/os-release ]; then
				distrib_id=$(</etc/os-release);
				for l in $(echo $distrib_id); do
					if [[ ${l} =~ ^ID= ]]; then
						distrib_id=${l//*=}
						break 1
					fi
				done
				if [[ -n ${distrib_id} ]]; then
					if [[ -n ${BASH_VERSINFO} && ${BASH_VERSINFO} -ge 4 ]]; then
						distrib_id=$(for i in ${distrib_id}; do echo -n "${i^} "; done)
						distro=${distrib_id% }
						unset distrib_id
					else
						distrib_id=$(for i in ${distrib_id}; do FIRST_LETTER=$(echo -n "${i:0:1}" | tr "[:lower:]" "[:upper:]"); echo -n "${FIRST_LETTER}${i:1} "; done)
						distro=${distrib_id% }
						unset distrib_id
					fi
				fi

				# Hotfixes
				[[ "${distro}" == "antergos" || "${distro}" == "Antergos" ]] && distro="Antergos"
				[[ "${distro}" == "Arch" ]] && distro="Arch Linux"
				[[ "${distro}" == "Archarm" || "${distro}" == "archarm" ]] && distro="Arch Linux"
				[[ "${distro}" == "elementary" ]] && distro="elementary OS"
			fi

			if [[ "${distro}" == "Unknown" ]]; then
				if [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" ]]; then
					if [ -f /etc/lsb-release ]; then
						LSB_RELEASE=$(</etc/lsb-release)
						distro=$(echo ${LSB_RELEASE} | awk 'BEGIN {
							distro = "Unknown"
						}
						{
							if ($0 ~ /[Uu][Bb][Uu][Nn][Tt][Uu]/) {
								distro = "Ubuntu"
								exit
							}
							else if ($0 ~ /[Mm][Ii][Nn][Tt]/ && $0 ~ /[Dd][Ee][Bb][Ii][Aa][Nn]/) {
								distro = "LMDE"
								exit
							}
							else if ($0 ~ /[Mm][Ii][Nn][Tt]/) {
								distro = "Mint"
								exit
							}
						} END {
							print distro
						}')
					fi
				fi
			fi

			if [[ "${distro}" == "Unknown" ]]; then
				if [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" ]]; then
					if [ -f /etc/arch-release ]; then distro="Arch Linux"
					elif [ -f /etc/chakra-release ]; then distro="Chakra"
					elif [ -f /etc/crunchbang-lsb-release ]; then distro="CrunchBang"
					elif [ -f /etc/debian_version ]; then distro="Debian"
					elif [ -f /etc/fedora-release ] && grep -q "Fedora" /etc/fedora-release; then distro="Fedora"
					elif [ -f /etc/frugalware-release ]; then distro="Frugalware"
					elif [ -f /etc/gentoo-release ]; then
						if grep -q "Funtoo" /etc/gentoo-release ; then
							distro="Funtoo"
						else
							distro="Gentoo"
						fi
					elif [ -f /etc/mageia-release ]; then distro="Mageia"
					elif [ -f /etc/mandrake-release ]; then distro="Mandrake"
					elif [ -f /etc/mandriva-release ]; then distro="Mandriva"
					elif [ -f /etc/SuSE-release ]; then distro="openSUSE"
					elif [ -f /etc/redhat-release ] && grep -q "Red Hat" /etc/redhat-release; then distro="Red Hat Enterprise Linux"
					elif [ -f /etc/redhat-release ] && grep -q "CentOS" /etc/redhat-release; then distro="CentOS"
					elif [ -f /etc/slackware-version ]; then distro="Slackware"
					elif [ -f /usr/share/doc/tc/release.txt ]; then distro="TinyCore"
					elif [ -f /etc/sabayon-edition ]; then distro="Sabayon"; fi
				else
					if [[ -x /usr/bin/sw_vers ]] && /usr/bin/sw_vers | grep -i "Mac OS X" >/dev/null; then
						distro="Mac OS X"
					elif [[ -f /var/run/dmesg.boot ]]; then
						distro=$(awk 'BEGIN {
							distro = "Unknown"
						}
						{
							if ($0 ~ /DragonFly/) {
								distro = "DragonFlyBSD"
								exit
							}
							else if ($0 ~ /FreeBSD/) {
								distro = "FreeBSD"
								exit
							}
							else if ($0 ~ /NetBSD/) {
								distro = "NetBSD"
								exit
							}
							else if ($0 ~ /OpenBSD/) {
								distro = "OpenBSD"
								exit
							}
						} END {
							print distro
						}' /var/run/dmesg.boot)
					fi
				fi
			fi
			if [[ "${distro}" == "Unknown" ]] && [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" ]]; then
				if [[ -f /etc/issue ]]; then
					distro=$(awk 'BEGIN {
						distro = "Unknown"
					}
					{
						if ($0 ~ /"LinuxDeepin"/) {
							distro = "LinuxDeepin"
							exit
						}
						else if ($0 ~ /"Parabola GNU\/Linux-libre"/) {
							distro = "Parabola GNU/Linux-libre"
							exit
						}
						else if ($0 ~ /"SolusOS"/) {
							distro = "SolusOS"
							exit
						}
					} END {
						print distro
					}' /etc/issue)
				fi
			fi
			if [[ "${distro}" == "Unknown" ]] && [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" ]]; then
				if [[ -f /etc/system-release ]]; then
					distro=$(awk 'BEGIN {
						distro = "Unknown"
					}
					{
						if ($0 ~ /"Scientific\ Linux"/) {
							distro = "Scientific Linux"
							exit
						}
					} END {
						print distro
					}' /etc/system-release)
				fi
			fi



		fi
	fi
	if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
		if [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -gt 1 ]] || [[ ${BASH_VERSINFO[0]} -gt 4 ]]; then
			distro=${distro,,}
		else
			distro="$(tr '[:upper:]' '[:lower:]' <<< ${distro})"
		fi
	else
		distro="$(tr '[:upper:]' '[:lower:]' <<< ${distro})"
	fi
	case $distro in
		antergos) distro="Antergos" ;;
		arch*linux*old) distro="Arch Linux - Old" ;;
		arch*linux) distro="Arch Linux" ;;
		arch) distro="Arch Linux";;
		'elementary'|'elementary os') distro="elementary OS";;
		fedora) distro="Fedora" ;;
		mageia) distro="Mageia" ;;
		mandriva) distro="Mandriva" ;;
		mandrake) distro="Mandrake" ;;
		mint) distro="Mint" ;;
		kali*linux) distro="Kali Linux" ;;
		lmde) distro="LMDE" ;;
		opensuse) distro="openSUSE" ;;
		ubuntu) distro="Ubuntu" ;;
		debian) distro="Debian" ;;
		raspbian) distro="Raspbian" ;;
		freebsd) distro="FreeBSD" ;;
		openbsd) distro="OpenBSD" ;;
		dragonflybsd) distro="DragonFlyBSD" ;;
		netbsd) distro="NetBSD" ;;
		red*hat*) distro="Red Hat Enterprise Linux" ;;
		crunchbang) distro="CrunchBang" ;;
		gentoo) distro="Gentoo" ;;
		funtoo) distro="Funtoo" ;;
		slackware) distro="Slackware" ;;
		frugalware) distro="Frugalware" ;;
		peppermint) distro="Peppermint" ;;
		solusos) distro="SolusOS" ;;
		parabolagnu|parabolagnu/linux-libre|'parabola gnu/linux-libre'|parabola) distro="Parabola GNU/Linux-libre" ;;
		viperr) distro="Viperr" ;;
		linuxdeepin) distro="LinuxDeepin" ;;
		chakra) distro="Chakra" ;;
		centos) distro="CentOS";;
		mac*os*x) distro="Mac OS X" ;;
		fuduntu) distro="Fuduntu" ;;
		manjaro) distro="Manjaro" ;;
		cygwin) distro="Cygwin" ;;
	esac
	[[ "$verbosity" -eq "1" ]] && verboseOut "Finding distro...found as '$distro $distro_release'"
}
# Distro Detection - End


# CPU Detection - Begin
detectcpu () {
	REGEXP="-r"
	if [ "$distro" == "Mac OS X" ]; then 
		cpu=$(echo $(sysctl -n machdep.cpu.brand_string))
		REGEXP="-E"
	elif [ "$distro" == "FreeBSD" ]; then cpu=$(sysctl -n hw.model)
	elif [ "$distro" == "DragonflyBSD" ]; then cpu=$(sysctl -n hw.model)
	elif [ "$distro" == "OpenBSD" ]; then cpu=$(sysctl -n hw.model | sed 's/@.*//')
	else
		cpu=$(awk 'BEGIN{FS=":"} /model name/ { print $2; exit }' /proc/cpuinfo | sed 's/ @/\n/' | head -1)
		if [ -z "$cpu" ]; then 
			cpu=$(awk 'BEGIN{FS=":"} /^cpu/ { gsub(/  +/," ",$2); print $2; exit}' /proc/cpuinfo | sed 's/, altivec supported//;s/^ //')
			if [[ $cpu =~ ^(PPC)*9.+ ]]; then
				model="IBM PowerPC G5 "
			elif [[ $cpu =~ 740/750 ]]; then
				model="IBM PowerPC G3 "
			elif [[ $cpu =~ ^74.+ ]]; then
				model="Motorola PowerPC G4 "
			elif [[ "$(cat /proc/cpuinfo)" =~ "BCM2708" ]]; then
				model="Broadcom BCM2835 ARM1176JZF-S"
			else
				model="IBM PowerPC G3 "
			fi
			cpu="${model}${cpu}"
		fi
		loc="/sys/devices/system/cpu/cpu0/cpufreq"
		if [ -f $loc/bios_limit ];then
			cpu_mhz=$(cat $loc/bios_limit | awk '{print $1/1000}')
		elif [ -f $loc/scaling_max_freq ];then
			cpu_mhz=$(cat $loc/scaling_max_freq | awk '{print $1/1000}')
		else
			cpu_mhz=$(awk -F':' '/cpu MHz/{ print int($2+.5) }' /proc/cpuinfo | head -n 1)
		fi
		if [ -n "$cpu_mhz" ];then
			if [ $cpu_mhz -gt 999 ];then
				cpu_ghz=$(echo $cpu_mhz | awk '{print $1/1000}')
				cpu="$cpu @ ${cpu_ghz}GHz"
			else
				cpu="$cpu @ ${cpu_mhz}MHz"
			fi
		fi
	fi
	cpu=$(echo "${cpu}" | sed $REGEXP 's/\([tT][mM]\)|\([Rr]\)|[pP]rocessor//g' | xargs)
	[[ "$verbosity" -eq "1" ]] && verboseOut "Finding current CPU...found as '$cpu'"
}
# CPU Detection - End