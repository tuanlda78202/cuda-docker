# CUDA Development Environment

This repository contains a Docker environment for CUDA development with Neovim, Python, Jupyter, and various development tools. The environment is based on NVIDIA's CUDA 12.4.1 image with Ubuntu 22.04.

## Prerequisites

- Docker installed on your system
- NVIDIA Container Toolkit installed
- NVIDIA GPU with compatible drivers
- Git

## Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/tuanlda78202/docker-env.git
cd docker-env
```

2. Ensure your directory structure matches the following:
```
.
├── Dockerfile
├── vim_setup/          # Neovim configuration files
├── dotfiles/
│   └── .zshrc         # ZSH configuration
├── scripts/
│   ├── create-user.sh
│   └── jupyterhub_config.py
```

3. Build the Docker image:
```bash
docker build -t cuda-dev -f cuda.Dockerfile .
```

## Running the Container

### Basic Usage

1. Start the container with GPU support:
```bash
docker run -d --gpus all \
  --name cuda-dev \
  -p 2222:2222 \
  -p 8888:8888 \
  cuda-dev
```

### Advanced Usage

For development work, mount your source code and configure additional ports:
```bash
docker run -d --gpus all --name cuda-dev \
  -p 2222:2222 \
  -p 8888:8888 \
  -v $(pwd)/workspace:/code \
  cuda-dev
```

## Accessing the Container

### SSH Access

1. Default credentials:
   - Username: root
   - Password: helloworld

2. Connect via SSH:
```bash
ssh -p 2222 root@localhost
```

### Direct Container Access

Access the container's shell directly:
```bash
docker exec -it cuda-dev zsh
```

## Development Environment Features

### Included Tools
- CUDA 12.4.1 with cuDNN
- Python 3.11
- Neovim (latest version)
- JupyterHub/JupyterLab
- tmux
- zsh with Oh My Zsh
- Various development tools (git, curl, etc.)

### GPU Monitoring
Monitor GPU usage using either:
```bash
nvtop     # GPU-specific monitoring
btop      # System-wide monitoring
```

### Jupyter Services

1. Start JupyterHub:
```bash
jupyterhub -f /code/jupyterhub_config.py
```

2. Access Jupyter in your browser:
```
http://localhost:8000
```

## Container Management

### Starting the Container
```bash
docker start cuda-dev
```

### Stopping the Container
```bash
docker stop cuda-dev
```

### Removing the Container
```bash
docker rm cuda-dev
```

## Customization

### Adding New Users

1. Execute the user creation script:
```bash
docker exec -it cuda-dev /start-scripts/create-user.sh <username>
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
   - Port 22 is not being used by another service
   - Your firewall allows connections to port 22

2. For GPU issues:
   - Verify GPU is visible: `nvidia-smi`
   - Check NVIDIA Container Toolkit installation: `nvidia-container-cli info`

3. For Jupyter access issues:
   - Check if the service is running: `ps aux | grep jupyter`
   - Verify port 8000 is not blocked
   - Check logs: `docker logs cuda-dev`

## Notes

- The root password is set to "helloworld" by default. Change it for production use.
- The container uses zsh as the default shell with Oh My Zsh configured.
- Neovim is built from source to ensure the latest version.
- The environment includes full CUDA development tools and can be used for GPU-accelerated applications.

## Security Considerations

For production environments:
1. Change the default root password
2. Disable root SSH access
3. Create non-root users
4. Configure SSH key authentication
5. Update the JupyterHub configuration with proper authentication