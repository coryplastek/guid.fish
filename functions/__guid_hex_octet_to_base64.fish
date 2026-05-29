function __guid_hex_octet_to_base64 -d 'Convert hex octet string to base64 (no endian swap)
Example: __guid_hex_octet_to_base64 9819c647c90dd246aa81a4079d691b10
         echo 9819c647c90dd246aa81a4079d691b10 | __guid_hex_octet_to_base64
         → mBnGR8kN0kaqgaQHnWkbEA=='
    set -l hex
    if set -q argv[1]
        set hex $argv[1]
    else
        read hex
    end
    if not string match -rq '^[0-9a-fA-F]{32}$' -- $hex
        echo "__guid_hex_octet_to_base64: expected 32 hex characters, got: '$hex'" >&2
        return 1
    end
    echo -n $hex | xxd -r -p | base64
end
