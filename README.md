# Linux TimeMachine (cli-only)

**[TL;DR](#tldr)** | **[Backups](#backups)** | **[Failures](#failures)** | **[Usage](#usage)** | **[License](#license)**

[![build status](https://travis-ci.org/cytopia/linux-timemachine.svg?branch=master)](https://travis-ci.org/cytopia/linux-timemachine)

This shell script mimics the behavior of OSX's timemachine. It uses rsync to incrementally backup your data to a different directory. All operations are incremental, atomic and automatically resumable.

By default the only rsync option used is `--recursive`. This is due to the fact that some remote NAS implementations do not support symlinks, changing owner, group or permissions (due to restrictive ACL's). If you want to use any of those options you can simply append them.

## TL;DR

```shell
# Recursive, incremental and atomic backup
$ timemachine /source/dir /target/dir

# Append rsync options
$ timemachine /source/dir /target/dir -- --archive --progress

# Make the timemachine script be more verbose
$ timemachine -v /source/dir /target/dir
$ timemachine -v /source/dir /target/dir -- --archive --progress
```

## Backups

The following directory structure will be created:
```
$ ls -la /my/backup/folder
2017-02-26__17_45_23/
2017-02-26__17_45_38/
2017-02-26__17_46_41/
2017-02-26__17_46_54/
current -> 2017-02-26__17_46_54/
```

`current` will always link to the latest created backup.
All backups are incremental except the first created one.
You can nevertheless safely remove all previous folders and the remaining folders will still have all of their content.

Backups are done incrementally, so least space is consumed. Due to `rsync`'s ability, every folder will still contain all files, even though they are just incremental backups. This is archived via hardlinks.
```
$ du -h .
497M    ./2017-02-26__17_45_23
24K     ./2017-02-26__17_45_38
24K     ./2017-02-26__17_46_41
24K     ./2017-02-26__17_46_54
497M    .
```

You can also safely delete the full backup folder without having to worry to loose any of your full backup data:
```
$ rm -rf ./2017-02-26__17_45_23
$ du -h .
497M    ./2017-02-26__17_45_38
24K     ./2017-02-26__17_46_41
24K     ./2017-02-26__17_46_54
497M    .
```

`rsync` is magic :-)


## Failures

In case the `timemachine` script aborts (self-triggered, disk unavailable or any other reason) you can simply run it again and it will automatically resume the last failed run.

There will be a directory `.inprogress/` in your specified destination. This will hold all already transferred data and will be picked up during the next run.


## Usage
```
$ timemachine -h

Usage: timemachine [-v] <source> <destination> -- [rsync opts]
       timemachine -V
       timemachine -h

This shell script mimics the behavior of OSX's timemachine.
It uses rsync to incrementally backup your data to a different directory.
All operations are incremental, atomic and automatically resumable.

By default the only rsync option used is --recursive.
This is due to the fact that some remote NAS implementations do not support
symlinks, changing owner, group or permissions (due to restrictive ACL's).
If you want to use any of those options you can simply append them.
See Example section for how to.

Required arguments:
  <source>        Source directory
  <destination>   Destination directory. Can also be a remote server

Options:
  -v, --verbose   Be verbose.

Misc Options:
  -V, --version   Print version information and exit
  -h, --help      Show this help screen

Examples:
  Simply backup one directory recursively
      timemachine /home/user /data
  Do the same, but be verbose
      timemachine -v /home/user /data
  Append rsync options and be verbose
      timemachine /home/user /data -- --links --times --perms --special
      timemachine --verbose /home/user /data -- --archive --progress --verbose
  Recommendation for cron run (no stdout, but stderr)
      timemachine /home/user /data -- -q
      timemachine /home/user -v /data -- --verbose > /var/log/timemachine.log
```

## License

[MIT License](LICENSE.md)
