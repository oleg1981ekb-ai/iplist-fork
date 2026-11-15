# 0001: macOS port and standalone binary packaging

## Status: Accepted

## Context
iplist was Linux-specific (whois -a, xargs ipcalc unavailable on macOS). ADR 0001 (cross-platform whois/ipcalc) covered command-level portability. This record covers packaging/distribution of the macOS port as a standalone self-contained binary so users don't need local PHP or Composer.

## Decision
Package with two layers:
1. box PHAR — application source, vendor, public assets bundled into build/iplist.phar (box.json at repo root).
2. static-php-cli (spc) micro build — standalone statically-linked PHP 8.5 binary with required extensions (ctype, dom, fileinfo, filter, iconv, libxml, mbstring, openssl, phar, tokenizer, xmlwriter, posix, pcntl, sockets).

Installed runtime layout:
- ~/.local/share/iplist/runtime/php — standalone static PHP binary (spc micro build)
- ~/.local/share/iplist/runtime/iplist.phar — box-packaged application PHAR
- ~/.local/bin/iplist — shell wrapper exec'ing the PHP binary with the PHAR

Default bind: 0.0.0.0:8080 (configurable via environment).

## Rationale
- Static PHP embeds all extensions (no system PHP needed).
- PHAR isolates app code from runtime (updates only replace PHAR).
- Wrapper keeps `iplist` on PATH while implementation lives in versioned runtime dir.

## Known caveats
- Amp\File has no ext-uv/ext-eio in the static build, falls back to ParallelFilesystemDriver using pcntl_fork (posix/pcntl extensions required). File operations under phar:// may be affected by this fallback.
- posix extension is mandatory; without it PosixRunner cannot spawn processes and the app crashes on startup.
- A combined single-file spc micro:combine executable (build/iplist-macos) was also produced during validation, but the separated php + phar + wrapper layout in ~/.local/share/iplist/runtime/ is the installed distribution form.

## Consequences
- Users install via ~/.local/bin/iplist wrapper; no host PHP/Composer required.
- Runtime config lives under ~/.local/share/iplist/runtime/ (via PATH_DATA).
- Releases require rebuilding static PHP and re-running box compile.

## Footnotes
1. Build commands (spc nightly x86_64; PHP 8.5.12 with --build-micro --build-cli --dl-with-php=8.5; box compile outputs build/iplist.phar).
2. Related ADR 0001-cross-platform-whois-ipcalc.md for command-level portability.
