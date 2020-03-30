# Linux Time Machine

**[Install](#tada-install)** |
**[Uninstall](#no_entry_sign-uninstall)** |
**[TL;DR](#coffee-tldr)** |
**[Features](#star-features)** |
**[How does it work](#information_source-how-does-it-work)** |
**[Restore](#recycle-restore)** |
**[Retention](#repeat-retention)** |
**[Usage](#computer-usage)** |
**[FAQ](#bulb-faq)** |
**[Disclaimer](#exclamation-disclaimer)** |
**[License](#page_facing_up-license)**

[![Linting](https://github.com/cytopia/linux-timemachine/workflows/Linting/badge.svg)](https://github.com/cytopia/linux-timemachine/actions?workflow=Linting)
[![Linux](https://github.com/cytopia/linux-timemachine/workflows/Linux/badge.svg)](https://github.com/cytopia/linux-timemachine/actions?workflow=Linux)
[![MacOS](https://github.com/cytopia/linux-timemachine/workflows/MacOS/badge.svg)](https://github.com/cytopia/linux-timemachine/actions?workflow=MacOS)
[![Tag](https://img.shields.io/github/tag/cytopia/linux-timemachine.svg)](https://github.com/cytopia/linux-timemachine/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

`linux-timemachine` is a tiny and stable [KISS](https://en.wikipedia.org/wiki/KISS_principle) driven and [POSIX](https://en.wikipedia.org/wiki/POSIX) compliant script that mimics the behavior of OSX's timemachine.
It uses [rsync](https://linux.die.net/man/1/rsync) to incrementally back up your data to a different
directory, hard disk or remote server via SSH. All operations are incremental, atomic and automatically resumable.

By default it uses the rsync options: `--recursive`, `--perms`, `--owner`, `--group`, `--times` and `--links`.
In case your target filesystem does not support any of those options or you cannot use them due
to missing permission, you can explicitly disable them via `--no-perms`, `--no-owner`, `--no-group`, `--no-times`,  and `--copy-links`.
See [FAQ](#bulb-faq) for examples.

**Motivation**

The goal of this project is to have a cross-operating system and minimal as possible backup script
that can be easily reviewed by anyone without great effort.
Additionally it should provide one task only and do it well without
the need of external requirements and only rely on default installed tools.


## :tada: Install
```bash
sudo make install
```


## :no_entry_sign: Uninstall
```bash
sudo make uninstall
```


## :coffee: TL;DR

Using [POSIX.1-2008](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html) argument syntax:

```bash
# Recursive, incremental and atomic backup (locally)
$ timemachine /source/dir /target/dir

# Recursive, incremental and atomic backup (via ssh)
$ timemachine /source/dir user@host:target/dir

# Recursive, incremental and atomic backup (via ssh with non-standard port)
$ timemachine --port 10000 /source/dir user@host:target/dir

# Append rsync options
$ timemachine /source/dir /target/dir -- --specials --progress
$ timemachine /source/dir /target/dir -- --specials --no-perms
$ timemachine /source/dir /target/dir -- --archive --progress

# Make the timemachine script be more verbose
$ timemachine -v /source/dir /target/dir
$ timemachine --verbose /source/dir /target/dir

# Make the timemachine script be even more verbose
$ timemachine -d /source/dir /target/dir
$ timemachine --debug /source/dir /target/dir

# Make the timemachine script and rsync more verbose
$ timemachine -v /source/dir /target/dir -- --verbose
$ timemachine --verbose /source/dir /target/dir -- --verbose
```


## :star: Features

| Feature | Description |
|---------|-------------|
| **SSH or local** | Local backups as well as backups via SSH are supported. |
| **Incremental**  | Backups are always done incrementally using rsync's ability to hardlink to previous backup directories. You can nevertheless always see the full backup on the file system of any incrementally made backup without having to generate it. This will also be true when deleting any of the previously created backup directories. See the [Backups](#backups) section for how this is achieved via rsync.<br/><br/>Incremental Backups also mean that only the changes on your source, compared to what is already on the target, have to be backed up. This will save you time as well as disk space on the target disk. |
| **Partial**      | When backing up, files are transmitted partially, so in case a 2GB movie file backup is interrupted the next run will pick up exactly where it left off at that file and will not start to copy it from scratch. |
| **Resumable**    | Not only is this script keeping partial files, but also the whole backup run is also resumable. Whenever there is an unfinished backup and you start `timemachine` again, it will automatically resume it. It will resume any previously failed backup as long as it finally succeeds. |
| **Atomic** <sup>[1]</sup> | The whole backup procedure is atomic. Only if and when the backup procedure succeeds, it is then properly named and symlinked. Any non-successful backup directory is either waiting to be resumed or to be deleted. |

* <sup>[1]</sup> The backup process is atomic, but not the backup itself. `rsync` copies files as it finds them and in the meantime there could already be changes on the source. To achieve an atomic backup, either back up from a read-only volume or from a snapshot.


## :information_source: How does it work?

### Directory structure

The following directory structure will be created:
```bash
$ tree -L 1 /my/backup/folder
.
├── 2018-01-06__18-43-30/
├── 2018-01-06__18-44-23/
├── 2018-01-06__18-50-44/
├── 2018-01-06__18-50-52/
└── current -> 2018-01-06__18-50-52/
```

`current` will always link to the latest created backup.
All backups are incremental except the first created one.
You can nevertheless safely remove all previous folders and the remaining folders will still have all of their content.

### Backup strategy

Except for the first one, backups are always and automatically done **incrementally**,
so the least amount of space is consumed.
Due to `rsync`'s ability, every directory will still contain all files, even though they are just
incremental backups. This is archived via hardlinks.
```bash
$ du -hd1 .
497M    ./2018-01-06__18-43-30
24K     ./2018-01-06__18-44-23
24K     ./2018-01-06__18-50-44
24K     ./2018-01-06__18-50-52
497M    .
```

You can also safely delete the initial full backup directory without having to worry about losing
any of your full backup data:
```bash
$ rm -rf ./2018-01-06__18-43-30
$ du -hd1 .
497M    ./2018-01-06__18-44-23
24K     ./2018-01-06__18-50-44
24K     ./2018-01-06__18-50-52
497M    .
```

`rsync` and [hardlinks](https://en.wikipedia.org/wiki/Hard_link) are magic :-)


### Failure handling and resume

In case the `timemachine` script aborts (self-triggered, disk unavailable or for any other reason)
you can simply run it again to automatically **resume** the last failed run.

This is due to the fact that the backup process is **atomic**. During a non-complete run,
all data will be stored in a directory named `.inprogress/`. This will hold all already
transferred data and will be picked up during the next run.
Once the backup is complete, it will be renamed and symlinked to `current`.
```bash
$ tree -a -L 1 /my/backup/folder
.
├── .inprogress/
├── 2018-01-06__18-43-30/
├── 2018-01-06__18-44-23/
├── 2018-01-06__18-50-44/
├── 2018-01-06__18-50-52/
└── current -> 2018-01-06__18-50-52/
```


## :recycle: Restore

No special software is required to restore your data. Backed up files can be easily browsed and
thus copied back to where you need them. Recall the backup directory structure:
```bash
$ tree -L 1 /my/backup/folder
.
├── 2018-01-06__18-43-30/
├── 2018-01-06__18-44-23/
├── 2018-01-06__18-50-44/
├── 2018-01-06__18-50-52/
└── current -> 2018-01-06__18-50-52/
```

Chose a backup directory and simply copy them to where you need it:
```bash
# Test it out in dry run mode before applying
$ rsync --archive --progress --dry-run /my/backup/folder/2018-01-06__18-50-52/ /src/

# Apply restoration
$ rsync --archive --progress /my/backup/folder/2018-01-06__18-50-52/ /src/
```


## :repeat: Retention

As decribed above this project is [KISS](https://en.wikipedia.org/wiki/KISS_principle) driven and only tries to do one job: **back up your data**.

Retention is a delicate topic as you want to be sure that data is removed as intended. For this there are already well-established tools that do an excellent job and have proven themselves over time: [tmpreaper](http://manpages.ubuntu.com/manpages/precise/man8/tmpreaper.8.html) and [tmpwatch](https://linux.die.net/man/8/tmpwatch).


## :computer: Usage

### Available options
```
$ timemachine -h

Usage: timemachine [-vdp] <source> <dest> -- [rsync opts]
       timemachine [-vdp] <source> <host>:<dest> -- [rsync opts]
       timemachine [-vdp] <source> <user>@<host>:<dest> -- [rsync opts]
       timemachine -V, --version
       timemachine -h, --help

This shell script mimics the behavior of OSX's timemachine.
It uses rsync to incrementally back up your data to a different directory or remote server via SSH.
All operations are incremental, atomic and automatically resumable.

By default it uses --recursive --perms --owner --group --times --links.
In case your target filesystem does not support any of those options, you can explicitly
disable those options via --no-perms --no-owner --no-group --no-times  and --copy-links.

Required arguments:
  <source>              Source directory
  <dest>                Destination directory.
  <host>:<dest>         SSH host and destination directory
  <user>@<host>:<dest>  SSH user, SSH host and destination directory

Options:
  -p, --port            Specify alternative SSH port for remote backups if it is not 22.
  -v, --verbose         Be verbose.
  -d, --debug           Be even more verbose.

Misc Options:
  -V, --version         Print version information and exit
  -h, --help            Show this help screen

Examples:
  Simply back up one directory recursively
      timemachine /home/user /mnt/bak
  Do the same, but be verbose
      timemachine -v /home/user /mnt/bak
  Append rsync options and be verbose
      timemachine -v /home/user /mnt/bak -- --archive --progress --verbose
  Log to file
      timemachine -v /home/user /mnt/bak > /var/log/timemachine.log 2> /var/log/timemachine.err
```

### Use with cron

The following can be used as an example crontab entry. It assumes you have an external disk (NFS, USB, etc..) that mounts at `/backup`. Before adding the crontab entry, ensure the filesystem in `/backup` is mounted and use:

```bash
$ touch /backup/mounted
```

This guards against accidentally backing up to an unmounted directory

Next, add the following to crontab using `crontab -e` as whichever user you intend to run the backup script as. You may need to place this in the root crontab if you are backing up sensitive files that only root can read

```bash
0 2 * * * if [[ -e /backup/mounted ]]; then /usr/local/bin/timemachine /home/someuser /backup; fi
```

This will cause `linux-timemachine` to run at 2AM once per day. Since `timemachine` keeps track of backups with granularity up to the hour, minute and second, you could have it run more than once per day if you want backups to run more often.


## :bulb: FAQ

**How to dry-run the backup?**
```bash
$ timemachine src/ dst/ -- --dry-run
```

**How to use a non-standard SSH port?**
```bash
$ timemachine --port 1337 src/ user@host:path/to/backup
```

**How to preserve ACLs?**
```bash
$ timemachine src/ dst/ -- --acls
```

**How to preserve extended attributes?**
```bash
$ timemachine src/ dst/ -- --xattrs
```

**How to disable preserving file and directory permissions?**
```bash
$ timemachine src/ dst/ -- --no-owner --no-perms
```

**How to disable preserving modification time?**
```bash
$ timemachine src/ dst/ -- --no-owner --no-times
```

**How to copy the content instead of a symlink?**
```bash
# This is useful in case your file system does not support symlinks.
# It is recommended to read rsync man page about symlinks to be sure
# about what you are doing
$ timemachine src/ dst/ -- --copy-links --safe-links
$ timemachine src/ dst/ -- --copy-links --safe-links --keep-dirlinks
```

**How to ensure all files in the back up have the ownership of current user?**
```bash
# Regardless of who owns the files, ensure the backup has uid and gid of current user
# This will only work if you have read-permission on all files.
$ timemachine src/ dst/ -- --no-owner --no-group

# If you do not have permission to read all files, you require sudo or root permission.
# The following will instruct rsync to ensure the backed up data has the uid and gid
# of the desired user.
$ sudo timemachine src/ dst/ -- --chown=<user>:<group>
```


## :exclamation: Disclaimer

Backups are one of the most important things. We all care about our data and want it to be safe,
so do not blindly trust scripts when it comes to backups!
Do [review the code](https://github.com/cytopia/linux-timemachine/blob/master/timemachine),
it is not too complex and kept as short as possible.

Learn about [rsync](https://linux.die.net/man/1/rsync) it is a very powerful tool and you might even
be able to just use this for backups.

There are many other backup tools out there that might be a better fit for your needs. Do your own
research, look at GitHub issues, source code and try out other projects.


## :page_facing_up: License

**[MIT License](LICENSE.md)**

Copyright (c) 2017 **[cytopia](https://github.com/cytopia)**
