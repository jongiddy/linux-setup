
#######################################
# LIQUID PROMPT DEFAULT TEMPLATE FILE #
#######################################

# Available features:
# LP_BATT battery
# LP_LOAD load
# LP_JOBS screen sessions/running jobs/suspended jobs
# LP_USER user
# LP_HOST hostname
# LP_PERM a colon ":"
# LP_PWD current working directory
# LP_VENV Python virtual environment
# LP_PROXY HTTP proxy
# LP_VCS the content of the current repository
# LP_ERR last error code
# LP_MARK prompt mark
# LP_TIME current time
# LP_RUNTIME runtime of last command
# LP_MARK_PREFIX user-defined prompt mark prefix (helpful if you want 2-line prompts)
# LP_PS1_PREFIX user-defined general-purpose prefix (default set a generic prompt as the window title)
# LP_PS1_POSTFIX user-defined general-purpose postfix
# LP_BRACKET_OPEN open bracket
# LP_BRACKET_CLOSE close bracket

# Remember that most features come with their corresponding colors,
# see the README.

LINE1="${LP_ERR}${LP_RUNTIME}${LP_TIME}${LP_BATT}${LP_LOAD}${LP_JOBS}${LP_PROXY}${LP_VENV}${LP_VCS}"
LINE2="${LP_USER}${LP_HOST}${LP_PERM}${LP_PWD}${LP_MARK_PREFIX}${LP_MARK}"
LP_PS1="${LINE1}\n${LINE2}"

# Add a title
LP_TITLE="$(_lp_title "${LP_TTYN}${LP_VENV}${LP_MARK_SHORTEN_PATH}\W${LP_MARK_SHORTEN_PATH}${LP_USER}${LP_HOST}${LP_PERM}${LP_PWD}")"
LP_PS1="${LP_TITLE}${LP_PS1}"
