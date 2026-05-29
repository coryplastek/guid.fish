function guid -d 'Convert between AD GUID formats: guid, hex, base64, ldap
Subcommands: to-guid, to-hex, to-base64, to-ldap, to-all
Auto-detects input format from the value.

Examples:
  guid to-base64 47c61998-0dc9-46d2-aa81-a4079d691b10
  guid to-guid "mBnGR8kN0kaqgaQHnWkbEA=="
  guid to-hex "mBnGR8kN0kaqgaQHnWkbEA=="
  guid to-ldap 47c61998-0dc9-46d2-aa81-a4079d691b10
  guid to-all 47c61998-0dc9-46d2-aa81-a4079d691b10
  guid to-all --json "mBnGR8kN0kaqgaQHnWkbEA=="
  echo 47c61998-0dc9-46d2-aa81-a4079d691b10 | guid to-base64'

    if test (count $argv) -lt 1
        echo "usage: guid <to-guid|to-hex|to-base64|to-ldap|to-all> [--json] <value>" >&2
        echo "       echo <value> | guid <to-guid|to-hex|to-base64|to-ldap|to-all> [--json]" >&2
        return 1
    end

    set -l subcmd $argv[1]
    set -l json_flag 0
    set -l value

    # Parse remaining args after subcommand
    for arg in $argv[2..]
        if test "$arg" = --json
            set json_flag 1
        else
            set value $arg
        end
    end

    # If no value from args, read from stdin
    if test -z "$value"
        read value
    end

    # --json is only valid with to-all
    if test $json_flag -eq 1 -a "$subcmd" != to-all
        echo "guid: --json is only supported with the to-all subcommand" >&2
        return 1
    end

    # Detect input format
    set -l fmt
    if string match -rq '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' -- $value
        set fmt guid
    else if string match -rq '^[A-Za-z0-9+/]{22}==$' -- $value
        set fmt base64
    else if string match -rq '^[0-9a-fA-F]{32}$' -- $value
        set fmt hex
    else
        echo "guid: unrecognized input format: '$value'" >&2
        echo "  expected: GUID (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx), hex (32 chars), or base64 (24 chars ending ==)" >&2
        return 1
    end

    switch $subcmd
        case to-guid
            switch $fmt
                case guid
                    echo $value
                case base64
                    __guid_base64_to_guid $value
                case hex
                    __guid_hex_octet_to_guid $value
            end
        case to-hex
            switch $fmt
                case hex
                    echo $value
                case guid
                    __guid_guid_to_hex_octet $value
                case base64
                    __guid_base64_to_hex_octet $value
            end
        case to-base64
            switch $fmt
                case base64
                    echo $value
                case guid
                    __guid_guid_to_base64 $value
                case hex
                    __guid_hex_octet_to_base64 $value
            end
        case to-ldap
            # LDAP needs hex octet format, then converts to \xx\xx escaping
            set -l hex_value
            switch $fmt
                case hex
                    set hex_value $value
                case guid
                    set hex_value (__guid_guid_to_hex_octet $value)
                case base64
                    set hex_value (__guid_base64_to_hex_octet $value)
            end
            __guid_hex_octet_to_ldap $hex_value
        case to-all
            # Compute all four representations
            set -l out_guid
            set -l out_hex
            set -l out_base64
            set -l out_ldap

            switch $fmt
                case guid
                    set out_guid $value
                    set out_hex (__guid_guid_to_hex_octet $value)
                    set out_base64 (__guid_guid_to_base64 $value)
                case hex
                    set out_guid (__guid_hex_octet_to_guid $value)
                    set out_hex $value
                    set out_base64 (__guid_hex_octet_to_base64 $value)
                case base64
                    set out_guid (__guid_base64_to_guid $value)
                    set out_hex (__guid_base64_to_hex_octet $value)
                    set out_base64 $value
            end
            set out_ldap (__guid_hex_octet_to_ldap $out_hex)

            if test $json_flag -eq 1
                echo "{"
                echo "  \"guid\": \"$out_guid\","
                echo "  \"hex\": \"$out_hex\","
                echo "  \"base64\": \"$out_base64\","
                echo "  \"ldap\": \"$out_ldap\""
                echo "}"
            else
                echo "guid:   $out_guid"
                echo "hex:    $out_hex"
                echo "base64: $out_base64"
                echo "ldap:   $out_ldap"
            end
        case '*'
            echo "guid: unknown subcommand '$subcmd'" >&2
            echo "  valid subcommands: to-guid, to-hex, to-base64, to-ldap, to-all" >&2
            return 1
    end
end
