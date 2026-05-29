function __guid_hex_octet_to_ldap -d 'Convert hex octet string to LDAP escaped filter format
Example: __guid_hex_octet_to_ldap 9819c647c90dd246aa81a4079d691b10
         echo 9819c647c90dd246aa81a4079d691b10 | __guid_hex_octet_to_ldap
         → \98\19\c6\47\c9\0d\d2\46\aa\81\a4\07\9d\69\1b\10'
    set -l hex
    if set -q argv[1]
        set hex $argv[1]
    else
        read hex
    end
    if not string match -rq '^[0-9a-fA-F]{32}$' -- $hex
        echo "__guid_hex_octet_to_ldap: expected 32 hex characters, got: '$hex'" >&2
        return 1
    end
    # using sed because fish's string replace can't produce literal
    # backslashes adjacent to capture group references in single-quoted
    # function bodies — the quoting layers collapse them.
    string lower -- $hex | sed "s/../\\\\&/g"
end
