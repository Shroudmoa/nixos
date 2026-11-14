function pack --description "Archive files and folders"
    if test (count $argv) -lt 1
        echo "Usage: pack <path> [format]"
        echo "Formats: zst (default), gz, xz, zip"
        return 1
    end

    set -l source $argv[1]
    set -l format zst

    if test (count $argv) -ge 2
        set format $argv[2]
    end

    if not test -e "$source"
        echo "Error: '$source' does not exist"
        return 1
    end

    set -l name (string replace -r '/$' '' -- "$source")
    set -l base (path basename "$name")

    switch $format
        case zst
            tar -I 'zstd -T0' -cvf "$base.tar.zst" -C (path dirname "$name") "$base"
        case gz
            tar -czvf "$base.tar.gz" -C (path dirname "$name") "$base"
        case xz
            tar -cJvf "$base.tar.xz" -C (path dirname "$name") "$base"
        case zip
            zip -r "$base.zip" "$source"
        case '*'
            echo "Unknown format: $format"
            return 1
    end
end

