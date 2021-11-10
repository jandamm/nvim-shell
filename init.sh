#!/usr/bin/env sh

__nvim-shell-check() { [ -n "$NVIM_LISTEN_ADDRESS" ] }
e() {
	# split
	if __nvim-shell-check; then
		nvr --remote "$@"
	else
		nvim "$@"
	fi
}

s() {
	# split
	if __nvim-shell-check; then
		nvr --remote -o "$@"
	else
		nvim "$@"
	fi
}

vs() {
	# vert split
	if __nvim-shell-check; then
		nvr --remote -O "$@"
	else
		nvim "$@"
	fi
}

t() {
	# tab
	if __nvim-shell-check; then
		nvr --remote-tab "$@"
	else
		nvim "$@"
	fi
}

vcopy() {
	__nvim-shell-check || return 1
	nvr -c "let @${1:-@""}=\"$(echo "$(</dev/stdin)" | sed -E 's/(["\])/\\\1/g')\""
}

vpaste() {
	__nvim-shell-check || return 1
	nvr --remote-expr "@${1:-@\"}"
}

vcd() {
	# switch *neovim's* working dir to $1
	__nvim-shell-check || return 1
	nvr -c "chdir ${1:-$PWD}"
}

vpwd() {
	__nvim-shell-check || return 1
	# print vim's current working dir
	nvr --remote-expr "getcwd()"
}

vwp() {
	# vim-window-print: send contents of a window out to stdout
	__nvim-shell-check || return 1
	local oldwin="$(nvr --remote-expr 'tabpagewinnr(tabpagenr())')"
	nvr -cc "$1wincmd w" --remote-expr 'join(getline(1,"$"), "\n")' -c "${oldwin}wincmd w"
}

vw() {
	__nvim-shell-check || return 1
	# remote nvim open file $2 in window $1
	if [ "$2" = "-" ]; then
		# allow piping stdin if '-' passed as filename
		cat | nvr -cc "$1wincmd w" --remote -
	else
		nvr -cc "$1wincmd w" -c "e $2"
	fi
}
