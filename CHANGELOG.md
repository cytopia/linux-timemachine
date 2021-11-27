# Changelog


## Release v1.3.1

#### Changed
- Switch to semver for versioning
- Change interpreter from POSIX sh to bash

#### Added
- CI: check for special chars in file names

#### Fixed
- Fixed `identityity` typo to `identity` in option parsing loop.


## Release v1.2

#### Fixed
- Fixed `identityity` typo to `identity` in option parsing loop.


## Release v1.1

#### Added
- [#60](https://github.com/cytopia/linux-timemachine/issues/60) Allow remote source
- Allow to specify SSH key (`-i` or `--identity`) for remote connections


## Release v1.0

#### Fixed
- Use correct SSH port when using SSH aliases from ~/.ssh/config

#### Added
- Integration and regression tests for Linux, MacOS and remote backups over SSH
- GitHub Actions integration

#### Removed
- Travis CI


## Release v0.9

#### Added
- [#9](https://github.com/cytopia/linux-timemachine/issues/9) Be able to backup to remote SSH host
- Add debug option
- Editorconfig


## Release v0.8

#### Changed
- [#22](https://github.com/cytopia/linux-timemachine/issues/22) Use `--owner`, `--group` and `--perms` by default


## Release v0.7

#### Changed
- [#21](https://github.com/cytopia/linux-timemachine/issues/21) No preservation of symlinks


## Release v0.6

#### Fixed
- [#30](https://github.com/cytopia/linux-timemachine/issues/30) Actually NOT incremental ?
- [#28](https://github.com/cytopia/linux-timemachine/issues/28) Incremental issue
- [#27](https://github.com/cytopia/linux-timemachine/issues/27) no hard links to old backups under busybox


## Release v0.5

#### Fixed
- Make incremental backups work


## Release v0.4

#### Added
- CHANGELOG
- Add GitHub Actions for Linux
- Add GitHub Actions for MacOS
- install/uninstall targets

#### Removed
- Travis CI checks (in favour of GitHub Actions)
