# CUDA Docker on Ubuntu Server
- [CUDA Docker on Ubuntu Server](#cuda-docker-on-ubuntu-server)
  - [Installation Steps](#installation-steps)
    - [Build using Docker Directly](#build-using-docker-directly)
    - [Build using Docker Compose](#build-using-docker-compose)
  - [Accessing the Container](#accessing-the-container)
    - [SSH Access](#ssh-access)
    - [Direct Container Access](#direct-container-access)
  - [Development Environment Features](#development-environment-features)
    - [Included Tools](#included-tools)
    - [Resource Monitoring](#resource-monitoring)
    - [Jupyter Services](#jupyter-services)
  - [Customization](#customization)
    - [Adding New Users](#adding-new-users)
    - [Updating CUDA Configurations](#updating-cuda-configurations)
  - [Troubleshooting](#troubleshooting)
  - [Acknowledgement](#acknowledgement)
  - [Contributors](#contributors)

| ![nvidia-docker](https://github.com/tuanlda78202/cuda-docker/blob/main/public/banner.png) | 
|:--:| 
| NVIDIA GPU within Docker Containers|
## Installation Steps

First, clone the repository:
```bash
git clone https://github.com/tuanlda78202/cuda-docker.git
cd cuda-docker
```
### Build using Docker Directly
1. Build the Docker image:
```bash
docker build -t cuda-dev-env -f cuda.Dockerfile .
```
2. Running the container from image:
```bash
docker run -d \
  --name cuda-dev-container \
  --gpus all \
  -p 2222:2222 \
  -p 8888:8888 \
  -v /dev/shm:/dev/shm \
  -v "$(pwd)/workspace:/root/workspace" \
  -v "$HOME/.ssh:/root/.ssh" \
  -v "$HOME/.gitconfig:/root/.gitconfig" \
  -v "$(pwd)/data:/root/data" \
  -v "$(pwd)/models:/root/models" \
  cuda-dev-env
```
### Build using Docker Compose

1. Build the container (only): 
```bash
docker compose build
```
2. Build and run using docker-compose:
```bash
docker compose up -d
```
3. Pause the container:
```bash
docker compose stop
```
4. Stop the container:
```bash
docker compose down
```

## Accessing the Container

### SSH Access

1. Default credentials:
```bash
username: root
password: helloworld
```

2. Connect via SSH:
```bash
ssh -p 2222 root@localhost
```

### Direct Container Access

Access the container's shell directly:
```bash
docker exec -it cuda-dev-container zsh
```

## Development Environment Features

### Included Tools
- CUDA 12.4.1 with cuDNN
- Python 3.11
- Neovim (latest version)
- JupyterHub/JupyterLab
- tmux
- zsh with Oh My Zsh
- Various development tools (git, conda, etc.)

### Resource Monitoring
Monitor CPU/GPU usage using either:
```bash
nvitop     # GPU-specific monitoring
btop       # System-wide monitoring
```

### Jupyter Services

1. Start JupyterHub:
```bash
jupyterhub -f /root/jupyterhub_config.py
```

2. Access Jupyter in your browser:
```
http://localhost:8888
```

## Customization

### Adding New Users

1. Execute the user creation script:
```bash
docker exec -it cuda-dev-container /start-scripts/create-user.sh <username>
```

2. Follow the prompts to set up the new user's password

### Updating CUDA Configurations

The clangd configuration for CUDA is located at `/root/.config/clangd/config.yaml`. Modify the GPU architecture as needed:
```yaml
CompileFlags:
  Add:
    - --cuda-gpu-arch=sm_86  # Change this to match your GPU architecture
```

## Troubleshooting

1. If you can't connect via SSH, ensure:
   - The container is running (`docker ps`)
   - Port 2222 is not being used by another service
   - Your firewall allows connections to port 2222

2. For GPU issues:
   - Verify GPU is visible: `nvidia-smi`
   - Check NVIDIA Container Toolkit installation: `nvidia-container-cli info`

3. For Jupyter access issues:
   - Check if the service is running: `ps aux | grep jupyter`
   - Verify port 8888 is not blocked
   - Check logs: `docker logs cuda-dev-container`

## Acknowledgement
This repository is based on [docker-env](https://github.com/tikikun/my_container) by Alan Dao and has been modified for an improved UI and enhanced usability in LLM workflows.

## Contributors 
<a href="https://github.com/tuanlda78202/cuda-docker/graphs/contributors">
<img src="https://contrib.rocks/image?repo=tuanlda78202/cod" /></a>
</a>