#!/usr/bin/env bash

DOTFILES_DIR="${HOME}/nixos-config/dotfiles"

usage() {
	cat <<EOF
Commands:
 add <program> <file_path>   - Move file to dotfiles and create symlink
 link <program/s>            - Create symlinks for program dotfiles
 unlink <program/s>          - Remove symlinks for program dotfiles
 delete <program/s>          - Delete program dotfiles directory
 list                        - List available program dotfiles
EOF
}

err() {
	echo "Error: $*" >&2
	exit 1
}

# expand_abs resolves a path with a leading "~" and makes it absolute.
expand_abs() {
	local path="$1"
	if [[ "$path" == "~" ]]; then
		path="$HOME"
	elif [[ "$path" == "~/"* ]]; then
		path="$HOME/${path:2}"
	fi
	realpath -m "$path"
}

# in_home checks that the given path is inside the home directory.
in_home() {
	local path="$1"
	[[ "$path" == "${HOME}/"* ]]
}

add_dot() {
	local dot_name="$1"
	local dot_path="$2"

	if [[ "$dot_name" == *".."* || "$dot_name" == *"/"* ]]; then
		err 'Program name cannot contain path separators or "..".'
	fi

	if [[ -L "${dot_path/#\~/$HOME}" ]]; then
		err "$dot_path is a link."
	fi

	local src_path="$DOTFILES_DIR/$dot_name"
	local abs_path
	abs_path="$(expand_abs "$dot_path")"

	if ! in_home "$abs_path"; then
		err "$abs_path is not in the home directory."
	fi
	if [[ ! -e "$abs_path" ]]; then
		err "$abs_path does not exist."
	fi

	local rel_path="${abs_path#"$HOME"/}"
	local target_path="$src_path/$rel_path"
	mkdir -p "${target_path%/*}"

	if ! mv "$abs_path" "$target_path"; then
		err "Failed to move $abs_path to $target_path"
	fi

	echo "Created new dot file at $src_path"
	link_dots "$dot_name"
}

link_dots() {
	for dot in "$@"; do
		local src_path="$DOTFILES_DIR/$dot"

		if [[ ! -e "$src_path" ]]; then
			echo "Error: $dot not found in dotfiles." >&2
			continue
		fi

		while IFS= read -r -d '' fp; do
			local rel_path="${fp#"$src_path"/}"
			local target_path="$HOME/$rel_path"

			local dir="${target_path%/*}"
			if [[ ! -d "$dir" ]]; then
				mkdir -p "$dir" || continue
			fi

			if [[ -e "$target_path" ]]; then
				echo "Error: $target_path already exists." >&2
				continue
			fi

			if ! ln -s "$fp" "$target_path"; then
				echo "Uncaught error: failed to link $fp" >&2
				continue
			fi
			echo "Linked: $rel_path"
		done < <(find "$src_path" ! -type d -print0)
	done
}

unlink_dots() {
	local dirs_to_remove=()

	for dot in "$@"; do
		local src_path="$DOTFILES_DIR/$dot"

		if [[ ! -e "$src_path" ]]; then
			echo "Error: $src_path does not exist." >&2
			continue
		fi

		while IFS= read -r -d '' fp; do
			local rel_path="${fp#"$src_path"/}"
			local target_path="$HOME/$rel_path"

			if [[ ! -e "$target_path" ]]; then
				echo "Error: $target_path does not exist." >&2
				continue
			fi
			if [[ ! -L "$target_path" ]]; then
				echo "Error: $target_path is not a link." >&2
				continue
			fi

			if ! rm "$target_path"; then
				echo "Uncaught error: failed to remove $target_path" >&2
				continue
			fi
			echo "Unlinked: $rel_path"
			dirs_to_remove+=("${target_path%/*}")
		done < <(find "$src_path" ! -type d -print0)
	done

	# Remove directories deepest-first; rmdir only removes empty ones.
	local sorted
	sorted="$(printf '%s\n' "${dirs_to_remove[@]}" | awk '{ print length, $0 }' | sort -rn | cut -d' ' -f2-)"
	while IFS= read -r dir; do
		rmdir "$dir" 2>/dev/null
	done <<<"$sorted"
}

delete_dots() {
	for dot in "$@"; do
		local src_path="$DOTFILES_DIR/$dot"

		if [[ ! -e "$src_path" ]]; then
			echo "Error: $src_path does not exist." >&2
			continue
		fi

		unlink_dots "$dot"

		if ! rm -rf "$src_path"; then
			echo "Uncaught error: failed to remove $src_path" >&2
			continue
		fi
		echo "Removed: $src_path"
	done
}

list_dots() {
	local -A total linked
	local linked_names=() unlinked_names=()

	if [[ ! -d "$DOTFILES_DIR" ]]; then
		err "$DOTFILES_DIR does not exist."
	fi

	while IFS= read -r -d '' fp; do
		local rel="${fp#"$DOTFILES_DIR"/}"
		local name="${rel%%/*}"
		[[ "$name" == ".git" ]] && continue

		local target="$HOME/${rel#"$name"/}"
		(( total["$name"]++ ))
		[[ -L "$target" ]] && (( linked["$name"]++ ))
	done < <(find "$DOTFILES_DIR" ! -type d -print0)

	local name dir
	shopt -s nullglob
	for dir in "$DOTFILES_DIR"/*/; do
		name="${dir%/}"
		name="${name##*/}"
		[[ "$name" == ".git" ]] && continue
		if [[ ! -v total["$name"] ]]; then
			linked_names+=("$name")
		fi
	done
	shopt -u nullglob

	for name in "${!total[@]}"; do
		if (( linked["$name"] == total["$name"] )); then
			linked_names+=("$name")
		else
			unlinked_names+=("$name")
		fi
	done

	if [[ ${#linked_names[@]} -gt 0 ]]; then
		mapfile -t linked_names < <(printf '%s\n' "${linked_names[@]}" | sort)
	fi
	if [[ ${#unlinked_names[@]} -gt 0 ]]; then
		mapfile -t unlinked_names < <(printf '%s\n' "${unlinked_names[@]}" | sort)
	fi

	if [[ ${#linked_names[@]} -gt 0 ]]; then
		echo "================"
		echo "=    Linked    ="
		echo "================"
		printf '%s\n' "${linked_names[@]}"
	fi

	if [[ ${#linked_names[@]} -gt 0 && ${#unlinked_names[@]} -gt 0 ]]; then
		echo
	fi

	if [[ ${#unlinked_names[@]} -gt 0 ]]; then
		echo "================"
		echo "=   Unlinked   ="
		echo "================"
		printf '%s\n' "${unlinked_names[@]}"
	fi

	if [[ ${#linked_names[@]} -gt 0 || ${#unlinked_names[@]} -gt 0 ]]; then
		echo
	fi
}

main() {
	if [[ $# -lt 1 ]]; then
		usage
		return
	fi

	for arg in "$@"; do
		if [[ "$arg" == ".git" ]]; then
			err 'Invalid arg ".git".'
		fi
	done

	case "$1" in
	add)
		if [[ $# -lt 3 ]]; then
			echo "Usage: add <program> <file_path>"
			return
		fi
		add_dot "$2" "$3"
		;;
	link)
		if [[ $# -lt 2 ]]; then
			echo "Usage: link <program/s>"
			return
		fi
		shift
		link_dots "$@"
		;;
	unlink)
		if [[ $# -lt 2 ]]; then
			echo "Usage: unlink <program/s>"
			return
		fi
		shift
		unlink_dots "$@"
		;;
	delete)
		if [[ $# -lt 2 ]]; then
			echo "Usage: delete <program/s>"
			return
		fi
		shift
		delete_dots "$@"
		;;
	list)
		list_dots
		;;
	*)
		usage
		;;
	esac
}

main "$@"
