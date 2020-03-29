# Linux TimeMachine (cli-only)

**[Install](#install)** | **[Uninstall](#uninstall)** | **[TL;DR](#tldr)** | **[Features](#features)** | **[Backups](#backups)** | **[Failures](#failures)** | **[Usage](#usage)** | **[Troubleshooting](#troubleshooting)** | **[License](#license)**

[![Linting](https://github.com/cytopia/linux-timemachine/workflows/Linting/badge.svg)](https://github.com/cytopia/linux-timemachine/actions?workflow=Linting)
[![Linux](https://github.com/cytopia/linux-timemachine/workflows/Linux/badge.svg)](https://github.com/cytopia/linux-timemachine/actions?workflow=Linux)
[![MacOS](https://github.com/cytopia/linux-timemachine/workflows/MacOS/badge.svg)](https://github.com/cytopia/linux-timemachine/actions?workflow=MacOS)
[![Tag](https://img.shields.io/github/tag/cytopia/linux-timemachine.svg)](https://github.com/cytopia/linux-timemachine/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This shell script mimics the behavior of OSX's timemachine.
It uses [rsync](https://linux.die.net/man/1/rsync) to incrementally back up your data to a different
directory or hard disk. All operations are incremental, atomic and automatically resumable.

By default it uses `--recursive`, `--perms`, `--owner`, `--group`, `--times` and `--links`.
In case your target filesystem does not support any of those options or you cannot use them due
to missing permission, you can explicitly disable those options via `--no-perms`, `--no-owner`, `--no-group`, `--no-times`,  and `--copy-links`.
See [Troubleshooting](#troubleshooting) for examples.


## Install
```bash
sudo make install
```


## Uninstall
```bash
sudo make uninstall
```


## TL;DR

Using [POSIX.1-2008](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html) argument syntax:

```bash
# Recursive, incremental and atomic backup
$ timemachine /source/dir /target/dir

# Append rsync options
$ timemachine /source/dir /target/dir -- --specials --progress
$ timemachine /source/dir /target/dir -- --specials --perms
$ timemachine /source/dir /target/dir -- --archive --progress

# Make the timemachine script be more verbose
$ timemachine -v /source/dir /target/dir
$ timemachine --verbose /source/dir /target/dir

# Make the timemachine script and rsync more verbose
$ timemachine -v /source/dir /target/dir -- --verbose
$ timemachine --verbose /source/dir /target/dir -- --verbose
```


## Features

#### Incremental

Backups are always done incrementally using rsync's ability to hardlink to previous backup directories. You can nevertheless always see the full backup on the file system of any incrementally made backup without having to generate it. This will also be true when deleting any of the previously created backup directories. See the [Backups](#backups) section for how this is achieved via rsync.

Incremental Backups also mean that only the changes on your source, compared to what is already on the target, have to be backed up. This will save you time as well as disk space on the target disk.

#### Partial

When backing up, files are transmitted partially, so in case a 2GB movie file backup is interrupted the next run will pick up exactly where it left off at that file and will not start to copy it from scratch.

#### Resumable

Not only is this script keeping partial files, but also the whole backup run is also resumable. Whenever there is an unfinished backup and you start `timemachine` again, it will automatically resume it. It will resume any previously failed backup as long as it finally succeeds.

#### Atomic

The whole backup procedure is atomic. Only if and when the backup procedure succeeds, it is then properly named and symlinked. Any non-successful backup directory is either waiting to be resumed or to be deleted.


## Backups

The following directory structure will be created:
```bash
$ /bin/ls -lFgG /my/backup/folder
drwxr-xr-x 3 4096 Jan  6 18:43 2018-01-06__18-43-30/
drwxr-xr-x 3 4096 Jan  6 18:44 2018-01-06__18-44-23/
drwxr-xr-x 3 4096 Jan  6 18:50 2018-01-06__18-50-44/
drwxr-xr-x 3 4096 Jan  6 18:50 2018-01-06__18-50-52/
lrwxrwxrwx 1   20 Jan  6 18:50 current -> 2018-01-06__18-50-52/
```

`current` will always link to the latest created backup.
All backups are incremental except the first created one.
You can nevertheless safely remove all previous folders and the remaining folders will still have all of their content.

Backups are done incrementally, so the least amount of space is consumed. Due to `rsync`'s ability, every folder will still contain all files, even though they are just incremental backups. This is archived via hardlinks.
```bash
$ du -hd1 .
497M    ./2018-01-06__18-43-30
24K     ./2018-01-06__18-44-23
24K     ./2018-01-06__18-50-44
24K     ./2018-01-06__18-50-52
497M    .
```

You can also safely delete the full backup folder without having to worry about losing any of your full backup data:
```bash
$ rm -rf ./2018-01-06__18-43-30
$ du -hd1 .
497M    ./2018-01-06__18-44-23
24K     ./2018-01-06__18-50-44
24K     ./2018-01-06__18-50-52
497M    .
```

`rsync` is magic :-)


## Failures

In case the `timemachine` script aborts (self-triggered, disk unavailable or any other reason) you can simply run it again to automatically resume the last failed run.

There will be a directory `.inprogress/` in your specified destination. This will hold all already transferred data and will be picked up during the next run.


## Usage
```
$ timemachine -h

Usage: timemachine [-v] <source> <destination> -- [rsync opts]
       timemachine -V
       timemachine -h

This shell script mimics the behavior of OSX's timemachine.
It uses rsync to incrementally back up your data to a different directory.
All operations are incremental, atomic and automatically resumable.

By default it uses --recursive --perms --owner --group --times --links.
In case your target filesystem does not support any of those options, you can explicitly
disable those options via --no-perms --no-owner --no-group --no-times  and --copy-links.

Required arguments:
  <source>        Source directory
  <destination>   Destination directory. Can also be a remote server

Options:
  -v, --verbose   Be verbose.

Misc Options:
  -V, --version   Print version information and exit
  -h, --help      Show this help screen

Examples:
  Simply back up one directory recursively
      timemachine /home/user /data
  Do the same, but be verbose
      timemachine -v /home/user /data
  Append rsync options and be verbose
      timemachine /home/user /data -- --no-perms
      timemachine --verbose /home/user /data -- --archive --progress --verbose
  Recommendation for cron run (no stdout, but stderr)
      timemachine /home/user /data -- -q
      timemachine /home/user -v /data -- --verbose > /var/log/timemachine.log
```


## Troubleshooting

### Disable preserving owner and group
```bash
$ timemachine src/ dst/ -- --no-owner --no-group
```

### Disable preserving permissions
```bash
$ timemachine src/ dst/ -- --no-owner --no-perms
```

### Disable preserving time
```bash
$ timemachine src/ dst/ -- --no-owner --no-times
```

### Target filesystem does not support symlinks
In case your target filesystem does not support symlinks, you can explicitly disable them and have
them copied as files via:
```bash
$ timemachine src/ dst/ -- --copy-links
$ timemachine src/ dst/ -- -L
```


## License

[MIT License](LICENSE.md)

Copyright (c) 2017 [cytopia](https://github.com/cytopia)
