#!/bin/sh
source $REDIS_HOME/script/include/helps.sh

get_alive_process | sort -k 3
