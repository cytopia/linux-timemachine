# Linux TimeMachine (cli-only)


It is basically an `rsync` script that mimics the behaviour of the famous OSX TimeMachine.

However, there is no timemachine server required as its core is simply rsync. You can sync to:

* local disk
* external disk
* remote server (rsync over ssh)

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


## Examples:

Whether you want to backup locally or remotely is automatically be read from your destination folder:
```
$ timemachine /home/user /data
$ timemachine /home/user user@host:/backup
```
