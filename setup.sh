#!/bin/sh

set -e -x

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

