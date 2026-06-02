# guid.fish

A [fisher](https://github.com/jorgebucaran/fisher) plugin for converting between Active Directory GUID representations. Handles the mixed-endian byte ordering that AD uses for `objectGUID` attributes, so you don't have to remember which bytes get swapped.

## Why?

Active Directory stores `objectGUID` as a 16-byte value with mixed-endian byte ordering -- the first three components are little-endian, the last two are big-endian. Microsoft refers to this this as `bytes_le` ordering. Different tools surface this value in different formats, and converting between them by hand is tedious and error-prone.

This plugin provides a single `guid` command that auto-detects the input format and converts to whichever output format you need.

## Installation

```fish
fisher install coryplastek/guid.fish
```

Requires `python3` (for endian-aware conversions) and standard Unix tools (`xxd`, `base64`, `sed`).

## Supported formats

All four formats represent the same underlying 16-byte value. Using GUID `47c61998-0dc9-46d2-aa81-a4079d691b10` as the reference:

| Format | Example | Description |
|--------|---------|-------------|
| GUID string | `47c61998-0dc9-46d2-aa81-a4079d691b10` | Standard `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` representation |
| Hex octet | `9819c647c90dd246aa81a4079d691b10` | 32 hex characters in AD byte order (little-endian for the first three components) |
| Base64 | `mBnGR8kN0kaqgaQHnWkbEA==` | Base64-encoded 16-byte payload, as stored in AD's `objectGUID` attribute |
| LDAP filter | `\98\19\c6\47\c9\0d\d2\46\aa\81\a4\07\9d\69\1b\10` | Backslash-escaped hex pairs for use in LDAP search filters |

Note that the hex octet and base64 formats reflect AD's mixed-endian byte order. The first four bytes of the hex octet (`9819c647`) are the GUID's first component (`47c61998`) reversed. This is not a generic UUID encoding -- it is specific to how Active Directory serializes GUIDs.

## Usage

```fish
guid <value>
guid <subcommand> <value>
```

The input format is auto-detected. Accepts a value as an argument or from stdin via pipe.

When no subcommand is given, `guid` defaults to `to-all` — showing all four format representations:

```fish
guid 47c61998-0dc9-46d2-aa81-a4079d691b10
# guid:   47c61998-0dc9-46d2-aa81-a4079d691b10
# hex:    9819c647c90dd246aa81a4079d691b10
# base64: mBnGR8kN0kaqgaQHnWkbEA==
# ldap:   \98\19\c6\47\c9\0d\d2\46\aa\81\a4\07\9d\69\1b\10

echo "mBnGR8kN0kaqgaQHnWkbEA==" | guid
# (same output)

guid --json 47c61998-0dc9-46d2-aa81-a4079d691b10
# { "guid": "...", "hex": "...", "base64": "...", "ldap": "..." }
```

### Subcommands

#### `to-guid`

Convert any format to a standard GUID string.

```fish
guid to-guid "mBnGR8kN0kaqgaQHnWkbEA=="
# 47c61998-0dc9-46d2-aa81-a4079d691b10

guid to-guid 9819c647c90dd246aa81a4079d691b10
# 47c61998-0dc9-46d2-aa81-a4079d691b10
```

#### `to-hex`

Convert any format to a 32-character hex octet string in AD byte order.

```fish
guid to-hex 47c61998-0dc9-46d2-aa81-a4079d691b10
# 9819c647c90dd246aa81a4079d691b10

echo "mBnGR8kN0kaqgaQHnWkbEA==" | guid to-hex
# 9819c647c90dd246aa81a4079d691b10
```

#### `to-base64`

Convert any format to base64.

```fish
guid to-base64 47c61998-0dc9-46d2-aa81-a4079d691b10
# mBnGR8kN0kaqgaQHnWkbEA==

guid to-base64 9819c647c90dd246aa81a4079d691b10
# mBnGR8kN0kaqgaQHnWkbEA==
```

#### `to-ldap`

Convert any format to LDAP filter escape syntax. Useful for constructing `objectGUID` search filters.

```fish
guid to-ldap 47c61998-0dc9-46d2-aa81-a4079d691b10
# \98\19\c6\47\c9\0d\d2\46\aa\81\a4\07\9d\69\1b\10
```

The output can be used directly in an LDAP filter:

```
(objectGUID=\98\19\c6\47\c9\0d\d2\46\aa\81\a4\07\9d\69\1b\10)
```

#### `to-all`

Print all four representations at once.

```fish
guid to-all 47c61998-0dc9-46d2-aa81-a4079d691b10
# guid:   47c61998-0dc9-46d2-aa81-a4079d691b10
# hex:    9819c647c90dd246aa81a4079d691b10
# base64: mBnGR8kN0kaqgaQHnWkbEA==
# ldap:   \98\19\c6\47\c9\0d\d2\46\aa\81\a4\07\9d\69\1b\10
```

Pass `--json` to get structured output:

```fish
guid to-all --json "mBnGR8kN0kaqgaQHnWkbEA=="
# {
#   "guid": "47c61998-0dc9-46d2-aa81-a4079d691b10",
#   "hex": "9819c647c90dd246aa81a4079d691b10",
#   "base64": "mBnGR8kN0kaqgaQHnWkbEA==",
#   "ldap": "\\98\\19\\c6\\47\\c9\\0d\\d2\\46\\aa\\81\\a4\\07\\9d\\69\\1b\\10"
# }
```

`--json` is only available with `to-all`.

### Piping

All subcommands accept input from stdin:

```fish
echo 47c61998-0dc9-46d2-aa81-a4079d691b10 | guid to-base64
# mBnGR8kN0kaqgaQHnWkbEA==

some-ad-query | guid to-ldap
```

### Passthrough

If the input is already in the requested format, the value is echoed back unchanged. Converting a GUID to a GUID is a no-op.

## Helper functions

The `guid` dispatcher delegates to internal functions:

| Function | Input | Output | Endian swap |
|----------|-------|--------|-------------|
| `__guid_base64_to_guid` | Base64 | GUID string | Yes (via `uuid.UUID(bytes_le=...)`) |
| `__guid_base64_to_hex_octet` | Base64 | Hex octet | No (raw byte decode) |
| `__guid_guid_to_base64` | GUID string | Base64 | Yes (via `uuid.bytes_le`) |
| `__guid_guid_to_hex_octet` | GUID string | Hex octet | Yes (via `uuid.bytes_le`) |
| `__guid_hex_octet_to_base64` | Hex octet | Base64 | No (raw byte encode) |
| `__guid_hex_octet_to_guid` | Hex octet | GUID string | Yes (via `uuid.UUID(bytes_le=...)`) |
| `__guid_hex_octet_to_ldap` | Hex octet | LDAP filter | No (format-only) |

Four helpers use Python's `uuid.UUID(bytes_le=...)` to handle the mixed-endian byte reordering. The remaining three operate on raw bytes without endian swapping -- base64 and hex octet are both direct representations of the same byte sequence, and LDAP is a formatting transform on hex octets.

Each helper validates its input and returns exit code 1 with a descriptive error message on failure.

## License

MIT
