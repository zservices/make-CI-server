#!/usr/bin/env zsh
#
# A z-service file that runs redis database server (redis-server).
#
# Use with plugin manager that supports single plugin load per all
# active Zsh sessions. The p-m should set parameters `ZSRV_WORK_DIR`
# and `ZSRV_ID`.
# These are the only two variables obtained from p-m and should
# be exported (apart from ZERO).

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Allow running the plugin as script if one desires (e.g. for debugging).
# The if checks if loaded from plugin manager or if the standard
# ZSRV_* vars are provided by it.
if [[ ${+zsh_loaded_plugins} == 0 || $zsh_loaded_plugins[(I)*/make-server] == 0 || \
    -z $ZSRV_WORK_DIR || -z $ZSRV_ID ]]; then
    typeset -gx ZSRV_WORK_DIR ZSRV_ID
    : ${ZSRV_WORK_DIR:=$0:h} ${ZSRV_ID:=make}
    export ZSRV_WORK_DIR ZSRV_ID
fi
ZSRV_WORK_DIR=${ZSRV_WORK_DIR%/.}

# Allow but strip non-number format codes, for future expansions.
# Implemented by `m` function/script.
m() {
    # No redundancy – reuse…
    $Plugins[MSERV_DIR]/functions/m "$@" \
        >>!$srv_logfile >>!$srv_loclogfile >>!$srv_cachelogfile;
}

# Own global and exported variables.
typeset -gx ZERO=$0 ZSRV_THIS_DIR=${0:h} \
    ZSRV_THIS_CACHE=${${ZSH_CACHE_DIR:+$ZSH_CACHE_DIR:h}:-${XDG_CACHE-HOME:-$HOME/.cache}}
ZSRV_THIS_CACHE+=/makesrv

integer -gx ZSRV_PID
typeset -gA Plugins
Plugins+=( MSERV_DIR "${0:h}"
    MSERV_CONF_INTERVAL "${MSERV_CONF_INTERVAL:=5}"
    MSERV_CONF_DIRS "$MSERV_CONF_DIRS"
    MSERV_CONF_ARGS "$MSERV_CONF_ARGS"
    MSERV_CONF_PAUSE_AFTER "${MSERV_CONF_PAUSE_AFTER:=30}" 
    MSERV_CONF_SETUP_ALIAS "$MSERV_CONF_SETUP_ALIAS" )

export MSERV_DIR MSERV_CONF_INTERVAL MSERV_CONF_DIRS \
    MSERV_CONF_ARGS MSERV_CONF_PAUSE_AFTER MSERV_CONF_SETUP_ALIAS

local pidfile=$ZSRV_WORK_DIR/$ZSRV_ID.pid \
        srv_logfile=$ZSRV_WORK_DIR/$ZSRV_ID.log \
        srv_loclogfile=$ZSRV_THIS_DIR/$ZSRV_ID.log \
        srv_cachelogfile=$ZSRV_THIS_CACHE/$ZSRV_ID.log \
        config=${XDG_CONFIG_HOME:-$HOME/.config}/makesrv/make-server.conf

command mkdir -p $config:h

# Test to detect lack of service'' ice if loaded from a plugin manager.
if (( !${+ZSRV_WORK_DIR} || !${+ZSRV_ID} )); then
    m {208}Error{39}:{70} plugin \`{174}zservices/make-server{70}\` needs to be loaded as service, aborting.
    return 1
fi

if [[ ! -f $config ]]; then
    command cp -f $ZSRV_THIS_DIR/make-server.conf $config || \
        config=$ZSRV_THIS_DIR/make-server.conf
fi

m ZSERVICE: Using config: $config

if [[ -r $config ]]; then
    { local pid=$(<$pidfile); } 2>/dev/null
    if [[ ${+commands[pkill]} -eq 1 && $pid = <-> && $pid -gt 0 ]]; then
        if command pkill -HUP -x -F $pidfile; then
            m ZSERVICE: Stopped previous make-server instance, PID: $pid
            LANG=C sleep 1.5
        else
            noglob m ZSERVICE: Previous make-server instance (PID:$pid) not running.
        fi
    fi

    builtin trap 'kill -INT $ZSRV_PID; command sleep 1; builtin exit 1' HUP
    () {
        emulate -L zsh -o multios
        # Output to three locations, one under Zinit home, second
        # in the plugin directory, third under ZICACHE/../{service-name}.log.0
        command mkdir -p $srv_cachelogfile:h
        command $ZSRV_THIS_DIR/make-server $config &>>!$srv_logfile \
                            &>>!$srv_loclogfile &>>!$srv_cachelogfile &
        # Remember PID of the server.
        ZSRV_PID=$!
    }
    # Save PID of the server.
    builtin print $ZSRV_PID >! $pidfile
    LANG=C command sleep 0.7
    builtin return 0
else
    m ZSERVICE: No readable make-server.conf found, make-server did not run 
    builtin return 1
fi
