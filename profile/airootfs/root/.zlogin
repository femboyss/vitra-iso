# fix for screen readers
if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

~/.automated_script.sh

# Vitra: start the graphical installer on tty1
if [[ $(tty) == /dev/tty1 ]] && ! grep -Fqa 'accessibility=' /proc/cmdline; then
    vitra-live
fi
