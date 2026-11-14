function f
    set -l file (fzf)
    if test -n "$file"
        $EDITOR $file
    end
end
