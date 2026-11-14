function unpack --description "Extract archives into their own directory"
    if test (count $argv) -ne 1
        echo "Usage: unpack <archive>"
        return 1
    end

    set -l archive $argv[1]

    if not test -f "$archive"
        echo "Error: '$archive' is not a file"
        return 1
    end

    set -l filename (path basename "$archive")
    set -l target (string replace -r '\.(tar\.zst|tar\.gz|tar\.xz|tar\.bz2|tgz|tbz2|txz|zip|7z|rar|gz|bz2|xz|zst)$' '' -- "$filename")

    if test "$target" = "$filename"
        echo "Error: Unsupported archive format"
        return 1
    end

    if test -e "$target"
        echo "Error: '$target' already exists"
        return 1
    end

    mkdir -p "$target"
    or return 1

    switch "$filename"
        case '*.tar.zst' '*.tzst'
            tar --zstd -xvf "$archive" -C "$target"
        case '*.tar.gz' '*.tgz'
            tar -xzvf "$archive" -C "$target"
        case '*.tar.xz' '*.txz'
            tar -xJvf "$archive" -C "$target"
        case '*.tar.bz2' '*.tbz2'
            tar -xjvf "$archive" -C "$target"
        case '*.tar'
            tar -xvf "$archive" -C "$target"
        case '*.zip'
            unzip "$archive" -d "$target"
        case '*.7z'
            7z x "$archive" "-o$target"
        case '*.rar'
            unrar x "$archive" "$target/"
        case '*.gz'
            gzip -dk "$archive"
            rmdir "$target"
            return
        case '*.bz2'
            bzip2 -dk "$archive"
            rmdir "$target"
            return
        case '*.xz'
            xz -dk "$archive"
            rmdir "$target"
            return
        case '*.zst'
            zstd -dk "$archive"
            rmdir "$target"
            return
        case '*'
            rmdir "$target"
            echo "Error: Unsupported archive format"
            return 1
    end

    if test $status -ne 0
        echo "Extraction failed. Partial files may remain in '$target'."
        return 1
    end

    echo "Extracted → $target/"
end

