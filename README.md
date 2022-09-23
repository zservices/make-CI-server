# make-server

Make server that runs in background for configured projects and periodically
builds them (i.e.: executes `make`) catching its output and exposing them
interactively via `zmake` command.

If your project's build is started earlier in the background, `zmake` will
show and follow its output. If it finished, it'll show its output without
blocking of terminal. You can also request last log of given *type*, i.e.:

- last successful, non-null build: `zmake -c/--clean`,
- last null build (no actions taken by the `Makefile`/`make`): `zmake -n/--null`,
- last warning-only build: `zmake -w/--warn`,
- last error build: `zmake -e/--err`.

## [zinit](https://github.com/zdharma-continuum/zinit)

A service-plugin needs a plugin manager that supports loading single plugin
instance per all active Zsh sessions, in background. zinit supports this, just
add:

```zsh
zinit param'MSERV_SRC_DIRS->{path to project:path to project:…}' service'make' \
        zservices/make-server
```

to `~/.zshrc`.

## Explanation of Zsh-spawned services

First Zsh instance that will gain a lock will spawn the service. Other Zsh
instances will wait. When you close the initial Zsh session, another Zsh will
gain lock and resume the service.
