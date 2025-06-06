# Use Debian stable slim as the base image. It includes glibc.
FROM debian:stable-slim

# Install necessary packages: wget, tar, and bash (for the start script)
# No need for glibc or glibc-compat here, as Debian comes with glibc.
# `apt-get clean` reduces image size by removing downloaded package lists.
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget tar bash ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Define TeamSpeak version and filename as build arguments (optional, but good practice)
ARG TS_VERSION="3.13.7"
ENV TS_FILENAME="teamspeak3-server_linux_amd64-${TS_VERSION}.tar.bz2"
ENV TS_DOWNLOAD_URL="https://files.teamspeak-services.com/releases/server/${TS_VERSION}/${TS_FILENAME}"
ENV TS_DIR_NAME="teamspeak3-server_linux_amd64"

# Create a non-root user for security best practice
# -m creates the home directory
# -s /bin/bash gives it a shell
RUN useradd -m -s /bin/bash teamspeak

# Set the working directory
WORKDIR /home/teamspeak

# Download and extract TeamSpeak server
RUN wget -q "${TS_DOWNLOAD_URL}" \
    && tar -xvf "${TS_FILENAME}" \
    && rm "${TS_FILENAME}" # Clean up the tar.bz2 file

# Navigate into the extracted directory
WORKDIR /home/teamspeak/${TS_DIR_NAME}

# Accept the TeamSpeak license
RUN touch .ts3server_license_accepted

# Give the teamspeak user ownership of the files in their home directory
RUN chown -R teamspeak:teamspeak /home/teamspeak

# Copy and chmod the start.sh script while still as root
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Switch to the non-root user
USER teamspeak

# Expose TeamSpeak's default ports
# UDP for voice
EXPOSE 9987/udp
# TCP for serverquery
EXPOSE 10011/tcp
# TCP for file transfer
EXPOSE 30033/tcp

# Command to run when the container starts
CMD ["/usr/local/bin/start.sh"]
