#!/bin/bash
#DISPLAY=:0 notify-send 'Starting WinBox via Wine'
DISPLAY=:0 kdialog --passivepopup 'Starting WinBox via Wine'
wine start /Unix "$HOME/Executables/winbox627.exe"
