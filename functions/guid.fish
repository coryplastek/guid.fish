function guid -d 'Convert between AD GUID formats'

    argparse h/help j/json -- $argv
    or return 1

    # Show help if --help/-h is passed, or if no arguments and no piped input
    if set -q _flag_help; or begin; test (count $argv) -lt 1; and isatty stdin; end
        echo "Convert between AD GUID formats: guid, hex, base64, ldap"
        echo "Subcommands: to-guid, to-hex, to-base64, to-ldap, to-all"
        echo "Auto-detects input format from the value."
        echo
        echo "Usage: guid <to-guid|to-hex|to-base64|to-ldap|to-all> [--json] <value>"
        echo "       echo <value> | guid <to-guid|to-hex|to-base64|to-ldap|to-all> [--json]"
        echo
        echo "Examples:"
        echo '  guid to-base64 47c61998-0dc9-46d2-aa81-a4079d691b10'
        echo '  guid to-guid "mBnGR8kN0kaqgaQHnWkbEA=="'
        echo '  guid to-hex "mBnGR8kN0kaqgaQHnWkbEA=="'
        echo '  guid to-ldap 47c61998-0dc9-46d2-aa81-a4079d691b10'
        echo '  guid to-all 47c61998-0dc9-46d2-aa81-a4079d691b10'
        echo '  guid to-all --json "mBnGR8kN0kaqgaQHnWkbEA=="'
        echo '  echo 47c61998-0dc9-46d2-aa81-a4079d691b10 | guid to-base64'
        return 0
    end

    set -l subcmd $argv[1]
    set -l value $argv[2]

    # If no value from args, read from stdin
    if test -z "$value"
        read value
    end

    # --json is only valid with to-all
    if set -q _flag_json; and test "$subcmd" != to-all
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

            if set -q _flag_json
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
