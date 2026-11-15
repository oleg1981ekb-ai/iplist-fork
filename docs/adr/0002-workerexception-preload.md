# 0002: WorkerException preload for clean PHAR shutdown

## Status: Accepted

## Context
When iplist is stopped via Ctrl+C (SIGINT), the PHP runtime enters shutdown. During this phase, `ContextWorkerPool::__destruct()` may attempt to instantiate `Amp\Parallel\Worker\WorkerException`. At that moment, the `phar://` stream is already closed and Composer's autoloader can no longer load classes from the archive, producing:

```
Fatal error: Class "Amp\Parallel\Worker\WorkerException" not found
```

This is a known issue with AMP parallel workers running inside a PHAR, where the class loading order during shutdown diverges from normal startup.

## Decision
Preload `WorkerException` (and any other worker exception classes that may be needed) immediately after `require_once __DIR__ . '/vendor/autoload.php';` in `index.php`:

```php
class_exists(\Amp\Parallel\Worker\WorkerException::class);
```

This forces the class to be loaded into memory during the early bootstrap phase, when both the autoloader and the `phar://` stream are still accessible. The `class_exists()` call without a second argument is safe: if the class does not exist, it returns `false` rather than throwing.

## Consequences
- Process exits cleanly after SIGINT with no `Fatal error` during shutdown.
- The PHAR is rebuilt (`box compile`) and copied to the runtime (`~/.local/share/iplist/runtime/iplist.phar`).
- No change to application behavior during normal operation — only affects shutdown class loading.
- Verified: `kill -INT <pid>` → `Received signal 2, stopping server` → `Stopped server`, exit code 0.

## Footnotes
1. The fix was committed as `406e2e7e` on `master`.
2. Related to ADR 0001-macos-port-and-standalone-binary.md (known caveat about `Amp\File` fallback to `ParallelFilesystemDriver`).
