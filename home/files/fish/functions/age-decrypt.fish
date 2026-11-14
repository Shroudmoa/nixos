function age-decrypt
    if test (count $argv) -ne 1
        echo "Usage: age-decrypt <file.age>"
        return 1
    end

    set -l input $argv[1]

    if not test -f "$input"
        echo "File not found: $input"
        return 1
    end

    if not string match -rq '\.age$' -- "$input"
        echo "File must end in .age"
        return 1
    end

    set -l output (string replace -r '\.age$' '' -- "$input")

    if test -e "$output"
        echo "Output already exists: $output"
        return 1
    end

    age -d -i ~/.config/age/identity.txt -o "$output" "$input"

    if test $status -eq 0
        echo "Decrypted: $output"
    end
end
