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

# Put as much config as possible in single directory
[ -d ${HOME}/.config ] || mkdir ${HOME}/.config

echo '# Personal login settings' > ${HOME}/.personalrc
echo 'source ${HOME}/.personalrc' >> ${HOME}/.bashrc

# Install liquidprompt
LIQUIDPROMPT_HOME=${HOME}/liquidprompt
if [ -r ${LIQUIDPROMPT_HOME}/liquidprompt ]; then
	(cd ${LIQUIDPROMPT_HOME}; git pull)
else
	while [ -d ${LIQUIDPROMPT_HOME} ]; do
		LIQUIDPROMPT_HOME=${LIQUIDPROMPT_HOME}/liquidprompt
	done
	git clone https://github.com/nojhan/liquidprompt.git ${LIQUIDPROMPT_HOME}
fi

cat >> ${HOME}/.personalrc <<EOF
# Only load Liquid Prompt in interactive shells, not from a script or from scp
[[ \$- = *i* ]] && source ${LIQUIDPROMPT_HOME}/liquidprompt
EOF

[ -d ${HOME}/.config/liquidprompt ] || mkdir ${HOME}/.config/liquidprompt
cp liquid.ps1 ${HOME}/.config/liquidprompt/liquid.ps1
cp liquidpromptrc ${HOME}/.config/liquidpromptrc

# Add Vagrant bash completion
VAGRANT_BASH_HOME=${HOME}/vagrant-bash-completion
if [ -r ${VAGRANT_BASH_HOME}/etc/bash_completion.d/vagrant ]; then
	(cd ${VAGRANT_BASH_HOME}; git pull)
else
	while [ -d ${VAGRANT_BASH_HOME} ]; do
		VAGRANT_BASH_HOME=${VAGRANT_BASH_HOME}/vagrant-bash-completion
	done
	git clone https://github.com/kura/vagrant-bash-completion.git ${VAGRANT_BASH_HOME}
fi

cat >> ${HOME}/.personalrc <<EOF
# Load Vagrant bash completion
source ${VAGRANT_BASH_HOME}/etc/bash_completion.d/vagrant
EOF
