# completions for guid.fish - AD GUID format converter

# disable file completions
complete -c guid -f

# subcommands (only when no subcommand has been given yet)
complete -c guid -n '__fish_use_subcommand' -a to-guid   -d 'Convert to GUID format (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)'
complete -c guid -n '__fish_use_subcommand' -a to-hex    -d 'Convert to hex octet format (32 hex chars)'
complete -c guid -n '__fish_use_subcommand' -a to-base64 -d 'Convert to base64 format'
complete -c guid -n '__fish_use_subcommand' -a to-ldap   -d 'Convert to LDAP escaped format (\\xx\\xx...)'
complete -c guid -n '__fish_use_subcommand' -a to-all    -d 'Show all formats at once'

# --json flag (only for to-all)
complete -c guid -n '__fish_seen_subcommand_from to-all' -l json -d 'Output as JSON'
