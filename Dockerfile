# Use a minimal base image. Alpine is often a good choice for size.
FROM alpine:3.18

# Install necessary packages: wget and tar
RUN apk add --no-cache wget tar bash glibc glibc-compat

# Define TeamSpeak version and filename as build arguments (optional, but good practice)
ARG TS_VERSION="3.13.7"
ENV TS_FILENAME="teamspeak3-server_linux_amd64-${TS_VERSION}.tar.bz2"
ENV TS_DOWNLOAD_URL="https://files.teamspeak-services.com/releases/server/${TS_VERSION}/${TS_FILENAME}"
ENV TS_DIR_NAME="teamspeak3-server_linux_amd64"

# Create a non-root user for security best practice
RUN adduser -D teamspeak

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
