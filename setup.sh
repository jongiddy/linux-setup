#!/bin/bash

set -e -x

SETUP_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ -r /etc/redhat-release ]; then
	YUM=true
else
	YUM=
fi

if [ -r /etc/os-release ]; then
	source /etc/os-release

	# Add Google DNS servers as backup to ISP DNS servers
	case "${ID}" in
	ubuntu)
		gdns_absent=
		grep -q 'pend domain-name-servers 8.8.' /etc/dhcp/dhclient.conf || gdns_absent=1
		if [ "${gdns_absent}" ]; then
			cp /etc/dhcp/dhclient.conf /tmp/$$.tmp
			echo 'append domain-name-servers 8.8.4.4;' >> /tmp/$$.tmp
			echo 'append domain-name-servers 8.8.8.8;' >> /tmp/$$.tmp
			sudo cp /tmp/$$.tmp /etc/dhcp/dhclient.conf
			rm /tmp/$$.tmp
		fi
		;;
	esac

	# Add SublimeText
	case "${ID}" in
	ubuntu)
		if [ ! -r /usr/bin/subl ]
		then
			wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
			sudo apt-get install -y apt-transport-https
			if [ ! -r /etc/apt/sources.list.d/sublime-text.list ]
			then
				echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
				sudo apt-get update
			fi
			sudo apt-get install -y sublime-text
		fi
		;;
	esac

	# Add git
	if [ ! `command -v git` ]; then
		case "${ID}" in
		ubuntu)
			sudo apt-get install -y git meld
			;;
		centos)
			sudo yum install -y git meld
			;;
		esac
	fi
fi

git config --global push.default simple
git config --global user.name "Jonathan Giddy"
# Make git prompt for email address for each repo
# Set it first to ensure unset does not exit with failure
git config --global user.email jongiddy@gmail.com
git config --global --unset user.email

if [ -r /usr/bin/meld ]; then
	git config --global merge.tool /usr/bin/meld
fi
if [ -r /usr/bin/subl ]; then
	git config --global core.editor "/usr/bin/subl --wait"
fi

# To keep this stuff out of my way, install packages in ~/.install and the
# configuration in ~/.config.
INSTALL=${HOME}/.install
CONFIG=${HOME}/.config

[ -d ${INSTALL} ] || mkdir ${INSTALL}
[ -d ${CONFIG} ] || mkdir ${CONFIG}

PERSONALRC=${CONFIG}/personalrc
echo '# Personal login settings' > ${PERSONALRC}
line="source ${PERSONALRC}"
grep -F "${line}" ${HOME}/.bashrc || echo "${line}" >> ${HOME}/.bashrc
grep -F "${line}" ${HOME}/.zshrc || echo "${line}" >> ${HOME}/.zshrc

#
# Install liquidprompt
#
LIQUIDPROMPT_HOME=${INSTALL}/liquidprompt
if [ -r ${LIQUIDPROMPT_HOME}/liquidprompt ]; then
	(cd ${LIQUIDPROMPT_HOME}; git pull)
else
	while [ -d ${LIQUIDPROMPT_HOME} ]; do
		LIQUIDPROMPT_HOME=${LIQUIDPROMPT_HOME}/liquidprompt
	done
	# Use my fork, which supports LP_TTYN
	git clone https://github.com/nojhan/liquidprompt.git ${LIQUIDPROMPT_HOME}
fi

cat >> ${PERSONALRC} <<EOF
# Only load Liquid Prompt in interactive shells, not from a script or from scp
[[ \$- = *i* ]] && source ${LIQUIDPROMPT_HOME}/liquidprompt
EOF

[ -d ${CONFIG}/liquidprompt ] || mkdir ${CONFIG}/liquidprompt
cp ${SETUP_DIR}/liquid.ps1 ${CONFIG}/liquidprompt/liquid.ps1
# Use ${HOME}/.config explicitly, since it is a fixed location in liquidprompt
[ -d ${HOME}/.config ] || mkdir ${HOME}/.config
cp ${SETUP_DIR}/liquidpromptrc ${HOME}/.config/liquidpromptrc

#
# Add Vagrant bash completion
#
VAGRANT_BASH_HOME=${INSTALL}/vagrant-bash-completion
if [ -r ${VAGRANT_BASH_HOME}/etc/bash_completion.d/vagrant ]; then
	(cd ${VAGRANT_BASH_HOME}; git pull)
else
	while [ -d ${VAGRANT_BASH_HOME} ]; do
		VAGRANT_BASH_HOME=${VAGRANT_BASH_HOME}/vagrant-bash-completion
	done
	git clone https://github.com/kura/vagrant-bash-completion.git ${VAGRANT_BASH_HOME}
fi

cat >> ${PERSONALRC} <<EOF
# Load Vagrant bash completion
[ -z "${BASH_VERSION}" ] || source ${VAGRANT_BASH_HOME}/etc/bash_completion.d/vagrant
EOF
