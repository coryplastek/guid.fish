function __guid_base64_to_hex_octet -d 'Convert AD base64 objectGUID to hex octet string
Example: __guid_base64_to_hex_octet "mBnGR8kN0kaqgaQHnWkbEA=="
         echo "mBnGR8kN0kaqgaQHnWkbEA==" | __guid_base64_to_hex_octet
         → 9819c647c90dd246aa81a4079d691b10'
    set -l b64
    if set -q argv[1]
        set b64 $argv[1]
    else
        read b64
    end
    if not string match -rq '^[A-Za-z0-9+/]{22}==$' -- $b64
        echo "__guid_base64_to_hex_octet: expected 24-char base64 (16-byte payload), got: '$b64'" >&2
        return 1
    end
    echo -n $b64 | base64 -d | xxd -p | tr -d '\n'
    echo
end
