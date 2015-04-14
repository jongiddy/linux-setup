#!/bin/sh

set -e -x

if [ -r /etc/redhat-release ]; then
	YUM=true
else
	YUM=
fi

if [ "${YUM}" ]; then
	sudo yum install -y git
else
	sudo apt-get install git
fi

# To keep this stuff out of my way, install packages in ~/.install and the
# configuration in ~/.config.
INSTALL=${HOME}/.install
CONFIG=${HOME}/.config

[ -d ${INSTALL} ] || mkdir ${INSTALL}
[ -d ${CONFIG} ] || mkdir ${CONFIG}

PERSONALRC=${CONFIG}/personalrc
echo '# Personal login settings' > ${PERSONALRC}
echo "source ${PERSONALRC}" >> ${HOME}/.bashrc

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
	git clone https://github.com/nojhan/liquidprompt.git ${LIQUIDPROMPT_HOME}
fi

cat >> ${PERSONALRC} <<EOF
# Only load Liquid Prompt in interactive shells, not from a script or from scp
[[ \$- = *i* ]] && source ${LIQUIDPROMPT_HOME}/liquidprompt
EOF

[ -d ${CONFIG}/liquidprompt ] || mkdir ${CONFIG}/liquidprompt
cp liquid.ps1 ${CONFIG}/liquidprompt/liquid.ps1
# Use ${HOME}/.config explicitly, since it is a fixed location in liquidprompt
[ -d ${HOME}/.config ] || mkdir ${HOME}/.config
cp liquidpromptrc ${HOME}/.config/liquidpromptrc

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
source ${VAGRANT_BASH_HOME}/etc/bash_completion.d/vagrant
EOF
