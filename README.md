# fridgital

A new Flutter project.

## Getting Started

### SQLite

#### Linux

`libsqlite3` and `libsqlite3-dev` linux packages are required.

One time setup for Ubuntu (to run as root):

`sudo apt-get -y install libsqlite3-0 libsqlite3-dev`


#### MacOS

Should work without any installations.

#### Windows

Add the `sqlite3.dll` in the same folder as the executable.

### build_runner

When developing, run the command `flutter pub run build_runner watch` to run build_runner in the background.