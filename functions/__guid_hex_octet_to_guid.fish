function __guid_hex_octet_to_guid -d 'Convert hex octet string to GUID string (AD byte order)
Example: __guid_hex_octet_to_guid 9819c647c90dd246aa81a4079d691b10
         echo 9819c647c90dd246aa81a4079d691b10 | __guid_hex_octet_to_guid
         → 47c61998-0dc9-46d2-aa81-a4079d691b10'
    set -l hex
    if set -q argv[1]
        set hex $argv[1]
    else
        read hex
    end
    if not string match -rq '^[0-9a-fA-F]{32}$' -- $hex
        echo "__guid_hex_octet_to_guid: expected 32 hex characters, got: '$hex'" >&2
        return 1
    end
    echo -n $hex | python3 -c '
import uuid, sys
hex_str = sys.stdin.read().strip()
guid = uuid.UUID(bytes_le=bytes.fromhex(hex_str))
print(str(guid))
'
end
