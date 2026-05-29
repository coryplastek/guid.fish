function __guid_guid_to_base64 -d 'Convert GUID string to AD base64 objectGUID
Example: __guid_guid_to_base64 47c61998-0dc9-46d2-aa81-a4079d691b10
         echo 47c61998-0dc9-46d2-aa81-a4079d691b10 | __guid_guid_to_base64
         → mBnGR8kN0kaqgaQHnWkbEA=='
    set -l guid
    if set -q argv[1]
        set guid $argv[1]
    else
        read guid
    end
    if not string match -rq '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' -- $guid
        echo "__guid_guid_to_base64: expected GUID format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx), got: '$guid'" >&2
        return 1
    end
    echo -n $guid | python3 -c '
import uuid, sys, base64
guid = uuid.UUID(sys.stdin.read().strip())
print(base64.b64encode(guid.bytes_le).decode())
'
end
