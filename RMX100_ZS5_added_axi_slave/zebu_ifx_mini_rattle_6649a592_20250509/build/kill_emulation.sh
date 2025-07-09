#!/bin/sh
################################################################
# kill_emulation.sh is designed to kill remaining process of an emulation after an abnormal close.
# It will send SIGKILL signal to all process involved in the current emulation.
# It will also remove files possibly remaining after the abnormal close.
# It uses the pid of the emulation process and specific filenames thus.
# this script can only be used once.
# 
# WARNING : this script sends SIGKILL, use it carefully!
################################################################
# kill the process
kill -9 1804687
sleep 1
kill -9 1804675
sleep 1
# remove remaining files
rm -f /zebu/queue/queue.rashour.4009376710.1804687.0.1750262025
