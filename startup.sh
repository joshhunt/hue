#!/bin/sh
cd /home/pi/hue
tmux new -d -s hue 'coffee app.coffee'
tmux rename-window 'Hue Main'
tmux attach -t hue