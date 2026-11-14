function age-encrypt
    if test (count $argv) -ne 1
        echo "Usage: age-encrypt <file>"
        return 1
    end

    set -l input $argv[1]
    set -l output "$input.age"

    if not test -f "$input"
        echo "File not found: $input"
        return 1
    end

    if test -e "$output"
        echo "Output already exists: $output"
        return 1
    end

    age -R ~/.config/age/recipients.txt -o "$output" "$input"

    if test $status -eq 0
        echo "Encrypted: $output"
    end
end
