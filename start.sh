#!/bin/bash

# Navigate to the TeamSpeak directory (assuming Dockerfile set WORKDIR correctly)
# This script should be placed where it can find the TeamSpeak server files relative to its execution.
# In the Dockerfile example, it will run from /home/teamspeak/teamspeak3-server_linux_amd64

echo "Starting TeamSpeak 3 Server..."
./ts3server_startscript.sh start

# Keep the container running by tailing /dev/null.
# The TeamSpeak server runs in the background.
echo "TeamSpeak server started in the background. Keeping container alive..."
tail -f /dev/null
