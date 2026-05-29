function __guid_guid_to_hex_octet -d 'Convert GUID string to hex octet string (AD byte order)
Example: __guid_guid_to_hex_octet 47c61998-0dc9-46d2-aa81-a4079d691b10
         echo 47c61998-0dc9-46d2-aa81-a4079d691b10 | __guid_guid_to_hex_octet
         → 9819c647c90dd246aa81a4079d691b10'
    set -l guid
    if set -q argv[1]
        set guid $argv[1]
    else
        read guid
    end
    if not string match -rq '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' -- $guid
        echo "__guid_guid_to_hex_octet: expected GUID format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx), got: '$guid'" >&2
        return 1
    end
    echo -n $guid | python3 -c '
import uuid, sys
guid = uuid.UUID(sys.stdin.read().strip())
print(guid.bytes_le.hex())
'
end
