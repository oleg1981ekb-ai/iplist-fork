<?php

use OpenCCK\Infrastructure\API\App;
use OpenCCK\Infrastructure\API\Server;

use Amp\ByteStream\BufferException;

require_once __DIR__ . '/vendor/autoload.php';

// Preload worker exceptions: ContextWorkerPool::__destruct() may need them
// during PHP shutdown, when the phar:// stream is already closed and
// Composer's autoloader can no longer load classes from the archive.
class_exists(\Amp\Parallel\Worker\WorkerException::class);

App::getInstance()
    ->addModule(
        /**
         * @throws Throwable
         * @throws BufferException
         */ fn(App $app) => Server::getInstance()
    )
    ->start();
