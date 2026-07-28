# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# set the editor
EDITOR=nvim

# Set the shell options
# ignoreeof only works upto 19 Ctrl+D Presses)
set -o emacs -o notify -o globstar -o ignoreeof -o globcasedetect -o nobackslashctrl

# noclobber
# Do not overwrite files when redirecting output by default.
# To manually overwrite a file while noclobber is set:
# echo "output" >| file.txt
set -C

# Get the effective user ID now to avoid running id(1) every time $PS1 is printed
integer euid=$(id -u)

# get some more stuff now
HOST="$(uname -n)"

# Specify search path for autoloadable functions
FPATH=/usr/share/ksh/functions:~/.func

# Optional: Autoload functions installed with ksh
autoload autocd cd dirs man mcd popd pushd

# Optional: Set the precision of the time keyword to six and use %C
TIMEFORMAT=$'\nreal\t%6lR\ncpu\t%6lC'

# Optional: Avoid certain file types in completion
FIGNORE='@(*.o|~*)'

# Save more commands in history
HISTSIZE=2000
HISTEDIT=$EDITOR

# Wrap the following commands for interactive use to avoid accidental file overwrites.
rm() { command rm -i -v "${@}"; }
cp() { command cp -i -v "${@}"; }
mv() { command mv -i -v "${@}"; }

mp() {
    typeset dir=${2%/*}
    [[ $dir == "$2" ]] && dir=.
    mkdir -p "$dir" && cp "$1" "$2"
}

# Remove the problematic default 'r' alias (this is only
# done when it's safe, as old versions of ksh can crash
# after 'unalias r').
((.sh.version >= 20220806)) && unalias r

# Below is a basic example that provides extra tilde expansions
if ((.sh.version >= 20210318)) && ((euid != 0)); then
    .sh.tilde.get()
    {
        case ${.sh.tilde} in
        '~docs')   .sh.tilde=~/Documents ;;
        '~dls')    .sh.tilde=~/Downloads ;;
        '~share')  .sh.tilde=~/.local/share ;;
        esac
    }
fi

# Associative array containing a set of RGB color codes.
# Terminals emulators with support for wide color ranges
# can take better advantage of this.
typeset -A color=(
    [bright_lavender]=$'\E[38;2;191;148;228m'
    [red]=$'\E[38;2;255;0;0m'
    [cyan_process]=$'\E[38;2;0;183;235m'
    [ultramarine_blue]=$'\E[38;2;65;102;245m'
    [emerald_green]=$'\E[38;2;16;185;129m'
    [mint_fresh]=$'\E[38;2;110;231;183m'
    [deep_purple]=$'\E[38;2;109;40;217m'
    [hot_pink]=$'\E[38;2;236;72;153m'
    [coral_sunset]=$'\E[38;2;255;127;80m'
    [golden_yellow]=$'\E[38;2;255;193;7m'
    [slate_gray]=$'\E[38;2;112;128;144m'
    [charcoal]=$'\E[38;2;54;54;54m'
    [lime_bright]=$'\E[38;2;50;205;50m'
    [ocean_blue]=$'\E[38;2;0;105;148m'
    [rose_pink]=$'\E[38;2;255;105;180m'
    [teal_dark]=$'\E[38;2;0;102;102m'
    [peach]=$'\E[38;2;255;183;97m'
    [violet_deep]=$'\E[38;2;138;43;226m'
    [sage_green]=$'\E[38;2;157;175;144m'
    [orange_vibrant]=$'\E[38;2;255;140;0m'
    [indigo]=$'\E[38;2;75;0;130m'
    [reset]=$'\E[0m'
    # Some extra examples
    [start_title]=$'\E]0;'
    [bell]=$'\a'
    [underline]=$'\E[4m'
    [spaced_dots]=$'\E[4:5m'
)

PS1.get()
{
    ret=$?  # Workaround $? bug in ksh < 2021-03-16 (cf. https://github.com/ksh93/ksh/pull/226)

    pwd=$(pwd 2>/dev/null)
    case ${pwd} in
        ~)      pwd='~' ;;
        ~/*)    pwd="~${pwd#~}" ;;
        '')     pwd="${color[red]}No pwd found" ;;
        / | * ) ;;  # Do nothing
    esac
    if ((euid == 0)); then
        .sh.value='$USER@$HOST ${color[bright_lavender]}${pwd} ${color[red]}#${color[reset]} '
    else
        .sh.value='${color[start_title]}$pwd${color[bell]}${color[rose_pink]}$USER${color[reset]}@${color[peach]}$HOST ${color[coral_sunset]}${pwd} ${color[cyan_process]}\$${color[reset]} '
    fi

    return $ret
}
# commands to skip setting terminal title for.
# these either finish too fast, or can be made to set the title themselves (eg: nvim)
typeset -A skip=(
    [case]=1 [fastfetch]=1 [neofetch]=1 [printf]=1 [print]=1
    [ls]=1   [cd]=1    [pwd]=1  [cat]=1 [lsblk]=1
    [grep]=1 [echo]=1  [mkdir]=1 [rm]=1
    [cp]=1   [mv]=1    [pushd]=1 [popd]=1
    [dir]=1  [dirs]=1  [nvim]=1 [clear]=1
    [chmod]=1 [chown]=1 [jobs]=1 [bg]=1 [fg]=1
)

# Logic to set the terminal title.
# Relevant for kitty or any terminal that does not do it for ksh93.
trap '
    cmd=${.sh.command%% *}
    cmd=${cmd##*/}

    if [[ -n ${skip[$cmd]} ]]; then
        :
    else
        printf "${color[start_title]}%s${color[bell]}" "$cmd"
    fi
' DEBUG



# User specific part starts here

# Command(s) to run after starting shell
fastfetch

# Aliases
alias ls='ls -l -a -H --color=auto'

