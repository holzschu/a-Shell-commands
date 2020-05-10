# a-Shell-commands
shell commands, pre-compiled to webAssembly, ready to use in a-Shell

## Purpose

[a-Shell](https://github.com/holzschu/a-shell) is a terminal for iOS. Several commands are provided, pre-compiled to iOS format. With the latest release (1.4.x), you can also execute commands compiled to webAssemly (wasm). If the command creates, writes or reads local files, it is best to use the specific [WASK-sdk](https://github.com/holzschu/wasi-sdk). 

Once compiled to webAssembly, binaries can be shared with other users of a-Shell. Click on the command you want, download it to your iPad or iPhone, move it to `~/Documents/bin/` and use it (a-Shell will add ".wasm" at the end and call the webAssembly JIT compiler on commands that are in the PATH).

file, tree, ctags and readtags are also part of the a-Shell AppStore release.

## List of commands, with their source code:

- [ctags](https://github.com/holzschu/a-Shell-commands/releases/download/0.1/ctags.wasm)/[readtags](https://github.com/holzschu/a-Shell-commands/releases/download/0.1/readtags.wasm):  https://github.com/universal-ctags/ctags/
- [file](https://github.com/holzschu/a-Shell-commands/releases/download/0.1/file.wasm): https://github.com/file/file/
- [tree](https://github.com/holzschu/a-Shell-commands/releases/download/0.1/tree.wasm): http://mama.indstate.edu/users/ice/tree/



