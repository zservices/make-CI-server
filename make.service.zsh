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

MAKE_SERVER_SRC_DIRS=${~MAKE_SERVER_SRC_DIRS}

# Allow running the plugin as script if one desires (e.g. for debugging).
# The if checks if loaded from plugin manager.
if [[ ${+zsh_loaded_plugins} == 0 || $zsh_loaded_plugins[(I)*/make-server] == 0 ]]; then
    typeset -gx ZSRV_WORK_DIR ZSRV_ID
    : ${ZSRV_WORK_DIR:=$0:h} ${ZSRV_ID:=make}
    export ZSRV_WORK_DIR ZSRV_ID
fi

# Allow but strip format codes, for future expansions
m() { print -- "${@//\{[^\}]##\}/}"; }

# Test to detect lack of service'' ice if loaded from a plugin manager.
if (( !${+ZSRV_WORK_DIR} || !${+ZSRV_ID} )); then
    m {error}Error{hi}:{msg2} plugin \`{pid}zservices/make-server{msg2}\` needs to be loaded as service, aborting.
    return 1
fi

# Own global and exported variables.
typeset -gx ZERO=$0 ZSRV_DIR=${0:h} ZSRV_CACHE=$ZICACHE:h/makesrv
integer -gx ZSRV_PID
typeset -gA Plugins
Plugins+=( MAKE_SERVER_DIR $ZSRV_DIR )

local pidfile=$ZSRV_WORK_DIR/$ZSRV_ID.pid \
        logfile=$ZSRV_WORK_DIR/$ZSRV_ID.log \
        loclogfile=$ZSRV_DIR/$ZSRV_ID.log \
        cachelogfile=$ZSRV_CACHE/$ZSRV_ID.log \
        config=$ZSRV_DIR/make-server.conf

if [[ -r $config ]]; then
    { local pid=$(<$pidfile); } 2>/dev/null
    if [[ ${+commands[pkill]} -eq 1 && $pid = <-> && $pid -gt 0 ]]; then
        if command pkill -HUP -x -F $pidfile; then
            m ZSERVICE: Stopped previous make-server instance, PID: $pid >>!$logfile
            LANG=C sleep 1.5
        else
            noglob m ZSERVICE: Previous make-server instance (PID:$pid) not running >>!$logfile
        fi
    fi

    builtin trap 'kill -INT $ZSRV_PID; command sleep 1; builtin exit 1' HUP
    () {
        emulate -L zsh -o multios
        # Output to three locations, one under Zinit home, second
        # in the plugin directory, third under ZICACHE/../{service-name}.log.0
        command mkdir -p $cachelogfile:h
        $ZSRV_DIR/make-server $config &>>!$logfile &>>!$loclogfile \
                            &>>!$cachelogfile &
        # Remember PID of the server.
        ZSRV_PID=$!
    }
    # Save PID of the server.
    builtin print $ZSRV_PID >! $pidfile
    LANG=C command sleep 0.7
    builtin return 0
else
    m ZSERVICE: No readable make-server.conf found, make-server did not run >>!$logfile
    builtin return 1
fi
