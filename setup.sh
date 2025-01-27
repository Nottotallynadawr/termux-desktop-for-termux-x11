#!/data/data/com.termux/files/usr/bin/bash

## Author  : Aditya Shakya (adi1090x)
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x
## Modifier : Nadawr

## Termux Desktop : Setup GUI in Termux 

## ANSI Colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"

## Reset terminal colors
reset_color() {
	printf '\033[37m'
}

## Script Termination
exit_on_signal_SIGINT() {
    { printf "${RED}\n\n%s\n\n" "[!] Program Interrupted." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "${RED}\n\n%s\n\n" "[!] Program Terminated." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Banner
banner() {
	clear
    cat <<- EOF
		${RED}┌──────────────────────────────────────────────────────────┐
		${RED}│${GREEN}░░░▀█▀░█▀▀░█▀▄░█▄█░█░█░█░█░░░█▀▄░█▀▀░█▀▀░█░█░▀█▀░█▀█░█▀█░░${RED}│
		${RED}│${GREEN}░░░░█░░█▀▀░█▀▄░█░█░█░█░▄▀▄░░░█░█░█▀▀░▀▀█░█▀▄░░█░░█░█░█▀▀░░${RED}│
		${RED}│${GREEN}░░░░▀░░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░░░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░░░░${RED}│
		${RED}└──────────────────────────────────────────────────────────┘
		${BLUE}By : Aditya Shakya // @adi1090x
		${BLUE}Modified By Nadawr
	EOF
}

## Show usages
usage() {
	banner
	echo -e ${ORANGE}"\nInstall GUI (Openbox Desktop) on Termux"
	echo -e ${ORANGE}"Usages : $(basename $0) --install | --uninstall \n"
}

## Update, X11-repo, Program Installation
_pkgs=(bc bmon calc calcurse curl dbus desktop-file-utils elinks feh fontconfig-utils fsmon \
		geany git gtk2 gtk3 htop imagemagick jq leafpad man mpc mpd mutt ncmpcpp \
		ncurses-utils neofetch firefox obconf openbox openssl-tool polybar ranger rofi \
		startup-notification termux-x11-nightly termux-api thunar kitty vim wget xarchiver xbitmaps xcompmgr \
		xfce4-settings xfce4-terminal xmlstarlet xorg-font-util xorg-xrdb pulseaudio virglrenderer-android zsh)

setup_base() {
	echo -e ${RED}"\n[*] Installing Termux Desktop..."
	echo -e ${CYAN}"\n[*] Updating Termux Base... \n"
	{ reset_color; pkg autoclean; pkg update -y; pkg upgrade -y; }
	echo -e ${CYAN}"\n[*] Enabling Termux X11-repo... \n"
	{ reset_color; pkg install -y x11-repo; }
		echo -e ${CYAN}"\n[*] Enabling Termux tur-repo... \n"
	{ reset_color; pkg install -y tur-repo; }
	echo -e ${CYAN}"\n[*] Installing required programs... \n"
	for package in "${_pkgs[@]}"; do
		{ reset_color; pkg install -y "$package"; }
		_ipkg=$(pkg list-installed $package 2>/dev/null | tail -n 1)
		_checkpkg=${_ipkg%/*}
		if [[ "$_checkpkg" == "$package" ]]; then
			echo -e ${GREEN}"\n[*] Package $package installed successfully.\n"
			continue
		else
			echo -e ${MAGENTA}"\n[!] Error installing $package, Terminating...\n"
			{ reset_color; exit 1; }
		fi
	done
	reset_color
}

## Setup Termux Configs
setup_termux() {
	# configuring termux
	echo -e ${CYAN}"\n[*] Configuring Termux..."
	if [[ ! -d "$HOME/.termux" ]]; then
		mkdir $HOME/.termux
	fi
	# copy font
	cp $(pwd)/files/.fonts/icons/dejavu-nerd-font.ttf $HOME/.termux/font.ttf
	# color-scheme
	cat > $HOME/.termux/colors.properties <<- _EOF_
		background 		: #263238
		foreground 		: #eceff1

		color0  			: #263238
		color8  			: #37474f
		color1  			: #ff9800
		color9  			: #ffa74d
		color2  			: #8bc34a
		color10 			: #9ccc65
		color3  			: #ffc107
		color11 			: #ffa000
		color4  			: #03a9f4
		color12 			: #81d4fa
		color5  			: #e91e63
		color13 			: #ad1457
		color6  			: #009688
		color14 			: #26a69a
		color7  			: #cfd8dc
		color15 			: #eceff1
	_EOF_
	# button config
	cat > $HOME/.termux/termux.properties <<- _EOF_
		extra-keys = [ \\
		 ['ESC','|', '/', '~','HOME','UP','END'], \\
		 ['CTRL', 'TAB', '=', '-','LEFT','DOWN','RIGHT'] \\
		]	
  allow-external-apps = true
	_EOF_
	# change shell and reload configs

	{ termux-reload-settings; } \
	&& { echo -e "${GREEN}Settings reloaded successfully"; } \
	|| { echo -e "${MAGENTA}Failed to run $ termux-reload-settings. Restart app after installation is complete"; }

	{ termux-setup-storage; } \
	&& { echo -e "${GREEN}Ran termux-setup-storage successfully, you should now have a ~/storage folder"; } \
	|| { echo -e "${MAGENTA}Failed to execute $ termux-setup-storage"; }
}
## Configuration
setup_config() {
	# ensure /etc/machine-id exists for xfce4-settings
	# ref: issue #110 - https://github.com/adi1090x/termux-desktop/issues/110
	#
	# Check if ${PREFIX}/etc/machine-id exists, if not, generate it
	if [[ $(find ${PREFIX}/etc/ -type f -name machine-id | wc -l) == 0 ]]; then
		dbus-uuidgen --ensure=/data/data/com.termux/files/usr/etc/machine-id
		machineUUID=$(cat ${PREFIX}/etc/machine-id)
		echo -e ${CYAN}"\n[*] Generated UUID: ${machineUUID}"
		reset_color
	fi

	# backup
	configs=($(ls -A $(pwd)/files))
	echo -e ${RED}"\n[*] Backing up your files and dirs... "
	for file in "${configs[@]}"; do
		echo -e ${CYAN}"\n[*] Backing up $file..."
		if [[ -f "$HOME/$file" || -d "$HOME/$file" ]]; then
			{ reset_color; mv -u ${HOME}/${file}{,.old}; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist."			
		fi
	done
	
	# Copy config files
	echo -e ${RED}"\n[*] Copiyng config files... "
	for _config in "${configs[@]}"; do
  		 echo -e ${CYAN}"\n[*] Chmodding"
		{ reset_color; chmod -R +x $(pwd)/files/$_config ; }
		echo -e ${CYAN}"\n[*] Copiyng $_config..."
		{ reset_color; cp -rf $(pwd)/files/$_config $HOME; }
	done
	if [[ ! -d "$HOME/Desktop" ]]; then
		mkdir $HOME/Desktop
	fi
}

## Create Launch Script
setup_launcher() {
	file="$HOME/.local/bin/startdesktop"
	if [[ -f "$file" ]]; then
		rm -rf "$file"
	fi
	echo -e ${RED}"\n[*] Creating Launcher Script... \n"
	{ reset_color; touch $file; chmod +x $file; }
	cat > $file <<- _EOF_
#!/bin/bash
## This Is Non-Hardware Accelerated, Made Only By Nadawr. btw

echo [!] Make Sure The X11 App Resolution Is Custom And Set To 1366x768! So It Fits Correctly And The App Lauches In 8 Secs
sleep 8
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
termux-x11 -xstartup 'openbox-session'

	_EOF_
 
 chmod +x $file
	
		file2="$HOME/.local/bin/startdesktopvirgl"
	if [[ -f "$file2" ]]; then
		rm -rf "$file2"
	fi
	echo -e ${RED}"\n[*] Creating Accelerated Launcher Script... \n"
	{ reset_color; touch $file; chmod +x $file; }
	cat > $file2 <<- _EOF_
#!/bin/bash
## This Is By phoenixbyrd All Of This Is Found On Termux XFCE install Script. So I Took It, Atleast I Gave Him Credits Huh?
## Btw This Is For Hardware Accelerated By Virgl
## Start Graphical Server
echo [!] Make Sure The X11 App Resolution Is Custom And Set To 1366x768! So It Fits Correctly And Everything Starts In 8 Secs
sleep 8
MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=4.3 virgl_test_server_android --angle-gl & > /dev/null 2>&1
sleep 1
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :1.0 &
sleep 1
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1
env DISPLAY=:1.0 GALLIUM_DRIVER=virpipe dbus-launch --exit-with-session openbox-session & > /dev/null 2>&1
	_EOF_
 
 chmod +x $file2
	
	if [[ -f "$file" ]]; then
		echo -e ${GREEN}"[*] Script ${ORANGE}$file ${GREEN}created successfully."
	fi
	
		if [[ -f "$file2" ]]; then
		echo -e ${GREEN}"[*] Script ${ORANGE}$file2 ${GREEN}created successfully."
	fi
	
	# defining PATH reference for ~/.local/bin in /etc/profile
	# to avoid issues with launching the whole script, when zsh / oh-my-zsh fails to install
	#   ref: https://github.com/adi1090x/termux-desktop/issues/99
	echo "export PATH=${PATH}:${HOME}/.local/bin" >> ${PREFIX}/etc/profile
	
	if [[ $(grep "export PATH.*/home/.local/bin" ${PREFIX}/etc/profile | wc -l) > 0 ]]; then
		echo -e ${GREEN}"[*] \$PATH reference ${ORANGE}~/.local/bin ${GREEN}added to /etc/profile successfully."
	fi
}

## Finish Installation
post_msg() {
	echo -e ${GREEN}"\n[*] ${RED}Termux Desktop ${GREEN}Installed Successfully.\n"
	cat <<- _MSG_
	
		[-] Restart termux and enter ${ORANGE}startdesktop ${GREEN}command to start the x11 server.
		[-] Before Startring The Desk, Open Termux-x11 App, Tap Settings, Set Display Resolution To Custom Then Set The Resolution To 1366x768, So It All Stays Correct.
		[-] Use ${ORANGE}Startdesktopvirgl To Do Hardware Accelerated Envoirment
		  
	_MSG_
	{ reset_color; exit 0; }
	
	# replace the current session's shell with zsh
	exec ${PREFIX}/bin/zsh
}

## Install Termux Desktop
install_td() {
	banner
	setup_base
	setup_termux
	setup_config
	setup_vnc
	setup_launcher
	post_msg
}

## Uninstall Termux Desktop
uninstall_td() {
	banner
	# remove pkgs
	echo -e ${RED}"\n[*] Unistalling Termux Desktop..."
	echo -e ${CYAN}"\n[*] Removing Packages..."
	for package in "${_pkgs[@]}"; do
		echo -e ${GREEN}"\n[*] Removing Packages ${ORANGE}$package \n"
		{ reset_color; apt-get remove -y --purge --autoremove $package; }
	done
	
	# delete files
	echo -e ${CYAN}"\n[*] Deleting config files...\n"
	_homefiles=(.fehbg .icons .mpd .ncmpcpp .fonts .gtkrc-2.0 .mutt .themes .vnc Music)
	_configfiles=(Thunar geany  gtk-3.0 leafpad netsurf openbox polybar ranger rofi xfce4)
	_localfiles=(bin lib 'share/backgrounds' 'share/pixmaps')
	for i in "${_homefiles[@]}"; do
		if [[ -f "$HOME/$i" || -d "$HOME/$i" ]]; then
			{ reset_color; rm -rf $HOME/$i; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"
		fi
	done
	for j in "${_configfiles[@]}"; do
		if [[ -f "$HOME/.config/$j" || -d "$HOME/.config/$j" ]]; then
			{ reset_color; rm -rf $HOME/.config/$j; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"			
		fi
	done
	for k in "${_localfiles[@]}"; do
		if [[ -f "$HOME/.local/$k" || -d "$HOME/.local/$k" ]]; then
			{ reset_color; rm -rf $HOME/.local/$k; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist.\n"			
		fi
	done
	echo -e ${RED}"\n[*] Termux Desktop Unistalled Successfully.\n"
}

## Main
if [[ "$1" == "--install" ]]; then
	install_td
elif [[ "$1" == "--uninstall" ]]; then
	uninstall_td
else
	{ usage; reset_color; exit 0; }
fi
