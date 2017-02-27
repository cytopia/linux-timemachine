# Linux TimeMachine (cli-only)


It is basically an `rsync` script that mimics the behaviour of the famous OSX TimeMachine.

However, there is no timemachine server required as its core is simply rsync. You can sync to:

* local disk
* external disk
* remote server (rsync over ssh)

Backups are done incrementally and if no full backup exists yet, it will be created and further backups are built upon. Again, no time machineserver is required.

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


## Examples:

Whether you want to backup locally or remotely is automatically be read from your destination folder:
```
$ timemachine /home/user /data
$ timemachine /home/user user@host:/backup
```

When you work with remote backups over ssh on a non-standard port, see here [SSH CONFIG](https://www.everythingcli.org/ssh-tunnelling-for-fun-and-profit-ssh-config/) for how to properly set up your ssh configuration file.
This will then allow you to simply use you aliases:
```
$ timemachine /home/user hosta:/backup
```

