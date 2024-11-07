# base frame of our container-image
FROM python:3.8.10-slim

# directory in the container that contains all files/assets of the project 
WORKDIR /app

# copies the files of the current folder from the host in the /app-directory of the container during build process 
COPY . $WORKDIR

# installs system-wide dependencies for compilation and network verification
# and delets cache files of package source information to reduce the size of the container
RUN apt-get update && \
    apt-get install -y build-essential gcc netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# installs the dependencies for the app and that are saved in the requirements.txt
RUN python -m pip install --upgrade pip && \
    python -m pip install -r requirements.txt

# sets the execution rights if the entrypoint-script is not executable.
# RUN chmod +x /app/entrypoint.sh
RUN chmod +x ./entrypoint.sh

# opens container port 5000 for interaction
EXPOSE 5000

# entrypoint is outsourced in /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]