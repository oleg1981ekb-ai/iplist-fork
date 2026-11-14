# 0001: Cross-platform whois and ipcalc replacement

## Status: Accepted

## Context
Porting to macOS and packaging into a standalone binary via box + static-php-cli (micro.sfx).
`whois -a` and `xargs ipcalc` are Linux-specific utilities not available on macOS.

## Decision
- Replace `whois -a` with cross-platform `whois` command (without the `-a` flag).
- Replace `... | xargs ipcalc | grep ...` pipeline with a pure-PHP method `ipRangeToCidrs()` that converts an IPv4 range (start-end) into the minimal set of CIDR blocks covering the range. This mirrors `ipcalc <start>-<end>` deaggregate output.

## Consequences
- External dependency on `ipcalc` binary is removed.
- Pure-PHP CIDR range conversion (`ipRangeToCidrs`) is added to `IP4Helper`.
- Verified output matches `ipcalc` deaggregate for test ranges: `1.2.3.4-1.2.3.10` → `1.2.3.4/30, 1.2.3.8/31, 1.2.3.10/32`.

## Footnotes
1. The `ipRangeToCidrs` method is placed before `trimCIDRs` in `src/Domain/Helper/IP4Helper.php`.
2. `whois` calls in `IP4Helper.php` and `IP6Helper.php` keep the `-a` flag removal only (the `-a` flag is Linux-specific).
