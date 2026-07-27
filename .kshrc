# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Increased history size
HISTSIZE=3000
HISTFILE="${HOME}/.ksh_history"

# Define colors using ksh93 non-printable wrappers (\001 and \002)
# This prevents the prompt from breaking line wrapping on long commands

# Reset
c_reset=$'\001\033[0m\002'

# Regular Colors
c_black=$'\001\033[0;30m\002'
c_red=$'\001\033[0;31m\002'
c_green=$'\001\033[0;32m\002'
c_yellow=$'\001\033[0;33m\002'
c_blue=$'\001\033[0;34m\002'
c_purple=$'\001\033[0;35m\002'
c_cyan=$'\001\033[0;36m\002'
c_white=$'\001\033[0;37m\002'

# Bold Colors
c_bblack=$'\001\033[1;30m\002'
c_bred=$'\001\033[1;31m\002'
c_bgreen=$'\001\033[1;32m\002'
c_byellow=$'\001\033[1;33m\002'
c_bblue=$'\001\033[1;34m\002'
c_bpurple=$'\001\033[1;35m\002'
c_bcyan=$'\001\033[1;36m\002'
c_bwhite=$'\001\033[1;37m\002'

# Background Colors (if needed)
c_bg_black=$'\001\033[40m\002'
c_bg_red=$'\001\033[41m\002'
c_bg_green=$'\001\033[42m\002'
c_bg_yellow=$'\001\033[43m\002'
c_bg_blue=$'\001\033[44m\002'
c_bg_purple=$'\001\033[45m\002'
c_bg_cyan=$'\001\033[46m\002'
c_bg_white=$'\001\033[47m\002'

# Retrieve short hostname
HOST=$(hostname -s 2>/dev/null || uname -n)

# PS1 variable
# We escape dynamic variables like $PWD so they evaluate every time the prompt is drawn
if [[ $(id -u) == 0 ]] ; then
    PS1="${c_bred}${HOST}${c_bblue} \${PWD##*/} # ${c_reset}"
else
    PS1="${c_bgreen}\${USER}@${HOST}${c_bblue} \${PWD} $ ${c_reset}"
fi


# Disable Ctrl+D exit (Only works upto 19 Ctrl+D Presses)
set -o ignoreeof

# Do not overwrite files when redirecting output by default.
# To manually overwrite a file while noclobber is set:
# echo "output" >| file.txt
#
set -o noclobber

# Print a literal like bash when Ctrl+C is pressed
# trap 'print "^C"' INT

# Enable emacs line editing mode
set -o emacs

# Reset title to 'ksh' and use a carriage return to recalculate prompt width
if [[ $- == *i* ]]; then
    PS1=$'\E]0;ksh\a\r'"$PS1"
fi

# Make ksh behave a lot more like Bash
keybd_trap () {
# 0. KITTY TAB TITLE: Catch Enter key and filter out fast commands
  if [[ -z ${_keybd_buf} && ( ${.sh.edchar} == $'\r' || ${.sh.edchar} == $'\n' ) ]]; then
    _cmd="${.sh.edtext}"
    
    # Extract just the first word (the command name)
    _first_word="${_cmd%% *}"
    
    # Check if the command is in our list of fast commands, or unwanted ones
    case "$_first_word" in
        ls|cd|pwd|echo|cat|clear|history|bg|fg|jobs|nvim) 
            # Do nothing. It is a fast command, so avoid the title flicker.
            ;;
        *)
            # It is not on the blacklist. Update the title instantly.
            printf "\033]0;%s\007" "$_cmd" > /dev/tty
            ;;
    esac
  fi

  # 1. Handle single-byte control keys (Ctrl+Backspace)
  if [[ -z ${_keybd_buf} && ${.sh.edchar} == $'\x08' ]]; then
    .sh.edchar=$'\e\x7f'
    return
  fi

  # 2. State Machine: Catch sequences starting with Escape or continue building
  if [[ ${.sh.edchar} == $'\e'* || -n ${_keybd_buf} ]]; then
    _keybd_buf+=${.sh.edchar}
    
    # If the buffer is exactly ESC, wait for the next character
    if [[ ${_keybd_buf} == $'\e' ]]; then
      .sh.edchar=''
      return
    fi

    # If it's ESC followed by anything other than '[' or 'O', it's not a control sequence
    # (e.g., standard Alt+B or Escape pressed manually). Release it immediately.
    if [[ ${_keybd_buf} == $'\e'[!\[O]* ]]; then
      .sh.edchar=${_keybd_buf}
      _keybd_buf=''
      return
    fi

    # If we are here, we are building an ESC [ or ESC O terminal sequence.
    # Terminal sequences always terminate with an alphabetical letter or a tilde.
    if [[ ${_keybd_buf} == *[a-zA-Z~] ]]; then
      case ${_keybd_buf} in
        $'\e[1;5D') .sh.edchar=$'\eb' ;; # Ctrl+Left -> Alt+B
        $'\e[1;5C') .sh.edchar=$'\ef' ;; # Ctrl+Right -> Alt+F
        $'\e[3;5~') .sh.edchar=$'\ed' ;; # Ctrl+Delete -> Alt+D
        $'\e[1;5A' | $'\e[1;5B') .sh.edchar='' ;; # Discard Ctrl+Up/Down
        $'\e[3~')   # Delete key with EOF protection
          if (( .sh.edcol < ${#.sh.edtext} )); then
            .sh.edchar=$'\004'
          else
            .sh.edchar=''
          fi
          ;;
        *) 
          # Unrecognized terminal sequence. Pass it through safely.
          .sh.edchar=${_keybd_buf} 
          ;;
      esac
      _keybd_buf='' # Reset buffer
    else
      # Incomplete sequence: swallow the current chunk and wait for the rest
      .sh.edchar=''
    fi
  fi
}

# Only apply the trap for interactive shell sessions
if [[ $- == *i* ]]; then
    trap keybd_trap KEYBD
fi

# --------------------------------

# User specific parts start here

# Commands to run after starting shell
fastfetch

# Wrap the following commands for interactive use to avoid accidental file overwrites.
rm() { command rm -i -v "${@}"; }
cp() { command cp -i -v "${@}"; }
mv() { command mv -i -v "${@}"; }

# Aliases

alias ls='ls -l -a -H --color=auto'


