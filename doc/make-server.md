% ZMAKE(1)
% Sebastian Gniazdowski
% 2022

# NAME
make-server - the (expected/but non-necessary) background script that performs periodical `make` executions
in given, configured directories.

# SYNOPSIS
*make-server* {config file}

# DESCRIPTION

Background service which compiles configured list of projects. To set it up
you can either:

 - export MSERV_CONF_DIRS variable supplying the projects' dirs via
   a colon separated list; e.g.: `export MSERV_CONF_DIRS={path1}:{path2}:…`,
 - or edit ~/.config/mkserv/make-server.conf`.

and then run `./make-server ~/.config/mksrv/make-server.conf`, for example.

That would be a manual, foreground run of the build service. You can also
run it in background either by executing `make.service.zsh` or by using
`Zinit` plugin manager, which will manage only a single instance of the
make-server:

```zsh
zinit service'make' param'MSERV_CONF_DIRS->~/github/project' for \
                zservices/make-server`
```

# CONFIGURATION VARIABLES

You can get the current full list of other `MSERV_*` variables by
looking at make-server.conf. The (rather also complete) register of
them is:

- **`MSERV_CONF_DIRS`** - a colon separated list of paths to the project
                        to compile,
- **`MSERV_CONF_INTERVAL`** - an integer which is the number of seconds between
                        build attempts,
- **`MSERV_CONF_ARGS`** - a colon separated list of argument given to `make`
                    command, e.g.: `MSERV_CONF_ARGS=-j3:-C doc`,
- **`MSERV_CONF_PAUSE_AFTER`** - an integet which is the number of `make` builds
                    yielding no difference in their output before sleeping
                    any future build on them if not unlocked.

# RESOURCES
*Project web site:* https://github.com/zservices/make-server

# COPYING

Copyright (C) 2022 Sebastian Gniazdowski

