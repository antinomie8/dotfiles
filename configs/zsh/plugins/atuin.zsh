# shellcheck disable=SC2034,SC2153,SC2086,SC2155

# Above line is because shellcheck doesn't support zsh, per
# https://github.com/koalaman/shellcheck/wiki/SC1071, and the ignore: param in
# ludeeus/action-shellcheck only supports _directories_, not _files_. So
# instead, we manually add any error the shellcheck step finds in the file to
# the above line ...

# Source this in your ~/.zshrc
autoload -U add-zsh-hook

zmodload zsh/datetime 2>/dev/null

# If zsh-autosuggestions is installed, configure it to use Atuin's search. If
# you'd like to override this, then add your config after the $(atuin init zsh)
# in your .zshrc
function _zsh_autosuggest_strategy_atuin() {
	function sql_escape() {
		print -r -- ${${@//\'/\'\'}//$'\x00'}
	}
	emulate -L zsh
	local input=$(sql_escape ${1}%)
	local last_cmd=$(sql_escape ${history[$((HISTCMD-1))]})
	local cwd=$(sql_escape $PWD)
	local reply=$(sqlite3 ~/.local/share/atuin/history.db "
SELECT command FROM (
	SELECT h1.*
	FROM history h1, history h2
	WHERE h1.ROWID = h2.ROWID + 1
		AND h1.session = h2.session
		AND h2.exit = 0
		AND h1.command LIKE '$input'
		AND h2.command = '$last_cmd'
		AND h1.cwd = '$cwd'
	ORDER BY timestamp DESC
	LIMIT 1
)
UNION ALL
SELECT command FROM (
	SELECT * FROM history WHERE cwd = '$cwd' AND command LIKE '$input' ORDER BY timestamp DESC LIMIT 1
)
UNION ALL
SELECT command FROM (
	SELECT * FROM history WHERE command LIKE '$input' ORDER BY timestamp DESC LIMIT 1
)
LIMIT 1
" 2>/dev/null)

	typeset -g suggestion=$reply
}

if [ -n "${ZSH_AUTOSUGGEST_STRATEGY:-}" ]; then
    ZSH_AUTOSUGGEST_STRATEGY=("atuin" "${ZSH_AUTOSUGGEST_STRATEGY[@]}")
else
    ZSH_AUTOSUGGEST_STRATEGY=("atuin")
fi

export ATUIN_SESSION=$(atuin uuid)
ATUIN_HISTORY_ID=""

_atuin_preexec() {
    local id
    id=$(atuin history start -- "$1")
    export ATUIN_HISTORY_ID="$id"
    __atuin_preexec_time=${EPOCHREALTIME-}
}

_atuin_precmd() {
    local EXIT="$?" __atuin_precmd_time=${EPOCHREALTIME-}

    [[ -z "${ATUIN_HISTORY_ID:-}" ]] && return

    local duration=""
    if [[ -n $__atuin_preexec_time && -n $__atuin_precmd_time ]]; then
        printf -v duration %.0f $(((__atuin_precmd_time - __atuin_preexec_time) * 1000000000))
    fi

    (ATUIN_LOG=error atuin history end --exit $EXIT ${duration:+--duration=$duration} -- $ATUIN_HISTORY_ID &) >/dev/null 2>&1
    export ATUIN_HISTORY_ID=""
}

add-zsh-hook preexec _atuin_preexec
add-zsh-hook precmd _atuin_precmd
