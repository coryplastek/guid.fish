function __guid_base64_to_guid -d 'Convert AD base64 objectGUID to GUID string
Example: __guid_base64_to_guid "mBnGR8kN0kaqgaQHnWkbEA=="
         echo "mBnGR8kN0kaqgaQHnWkbEA==" | __guid_base64_to_guid
         → 47c61998-0dc9-46d2-aa81-a4079d691b10'
    set -l b64
    if set -q argv[1]
        set b64 $argv[1]
    else
        read b64
    end
    if not string match -rq '^[A-Za-z0-9+/]{22}==$' -- $b64
        echo "__guid_base64_to_guid: expected 24-char base64 (16-byte payload), got: '$b64'" >&2
        return 1
    end
    echo -n $b64 | base64 -d | python3 -c '
import uuid, sys
guid = uuid.UUID(bytes_le=sys.stdin.buffer.read())
print(str(guid))
'
end
