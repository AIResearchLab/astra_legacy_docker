# astra_legacy_docker
Docker image for setting up astra legacy (first generation) cameras in AMD64 and ARM64 systems with ROS2 Humble

## Add this Docker container to other projects

Add the following snippet under `services` to any compose.yaml file to add this container.

```bash
  astra_legacy:
    image: ghcr.io/airesearchlab/astra_legacy:humble
    command: ros2 launch astra_camera astra_pro.launch.py
    restart: unless-stopped
    privileged: true
    network_mode: host
    volumes:
      - /dev:/dev
```

## Setup for Pulling container from ghcr.io

Clone this reposiotory

```bash
git clone https://github.com/AIResearchLab/astra_legacy_docker.git
```

Pull the Docker image and run Docker compose (No need to run `docker compose build`)
```bash
cd astra_legacy_docker
docker compose up
```

## Setup for building the container on device

Clone this reposiotory

```bash
git clone https://github.com/AIResearchLab/astra_legacy_docker.git
```

Build the Docker image
```bash
cd astra_legacy_docker
docker compose -f compose-build.yaml build
```

Start the docker container
```bash
docker compose -f compose-build.yaml up
```