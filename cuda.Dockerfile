# Stage 1: Build neovim
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 AS neovim-builder
RUN apt-get update && apt-get install -y --no-install-recommends \
  git \
  ca-certificates \
  build-essential \
  cmake \
  gettext \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /root
RUN git clone https://github.com/neovim/neovim \
  && cd neovim \
  && make CMAKE_BUILD_TYPE=RelWithDebInfo \
  && make install \
  && cd .. \
  && rm -rf neovim

# Stage 2: Final image
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Set ARGs for versions and reduce repetition
ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.11
ARG USER=root
ARG SHELL=/bin/zsh

# Copy neovim from builder
COPY --from=neovim-builder /usr/local/bin/nvim /usr/local/bin/
COPY --from=neovim-builder /usr/local/share/nvim /usr/local/share/nvim

# Install essential packages in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
  software-properties-common \
  make \
  build-essential \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  wget \
  tree \
  llvm \
  libncursesw5-dev \
  xz-utils \
  tk-dev \
  libxml2-dev \
  libxmlsec1-dev \
  libffi-dev \
  liblzma-dev \
  && add-apt-repository ppa:deadsnakes/ppa -y \
  && apt-get update && apt-get install -y --no-install-recommends \
  python${PYTHON_VERSION} \
  python${PYTHON_VERSION}-dev \
  zsh \
  nvtop \
  btop \
  tmux \
  git \
  curl \
  nano \
  ca-certificates \
  unzip \
  fd-find \
  nodejs \
  npm \
  nvidia-utils-535 \
  openssh-server \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 \
  && update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 100 \
  && rm -rf /var/lib/apt/lists/*

# Add Conda installation and setup
RUN wget -v https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
  && bash ~/miniconda.sh -b -p /opt/conda \
  && rm ~/miniconda.sh \
  && /opt/conda/bin/conda init zsh \
  && /opt/conda/bin/conda install python=3.11 -y \
  && /opt/conda/bin/conda config --set auto_activate_base true

# Add Conda to PATH
ENV PATH=/opt/conda/bin:$PATH \
  CONDA_DEFAULT_ENV=base

# Set environment variables
ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8 \
  SHELL=${SHELL}

# Configure SSH
RUN echo 'root:helloworld' | chpasswd \
  && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
  && mkdir -p /var/run/sshd \
  && mkdir -p /root/.config/clangd

# Setup clangd config
COPY <<EOF /root/.config/clangd/config.yaml
CompileFlags:
  Add:
    - --cuda-gpu-arch=sm_86
  Remove:
    - --generate-code=arch=*
    - -forward-unknown-to-host-compiler
EOF

# Install pip and Jupyter in a single layer
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python${PYTHON_VERSION} \
  && python -m pip install --no-cache-dir jupyterhub jupyterlab notebook ipywidgets nvitop poetry \
  && npm install -g configurable-http-proxy

# Configure Poetry to create virtual environments in the project directory
RUN poetry config virtualenvs.in-project true

# Setup zsh environment
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
  && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
  && git clone --depth 1 https://github.com/z-shell/F-Sy-H.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/F-Sy-H \
  && git clone --depth 1 https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions \
  && git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# Copy configuration files
COPY vim_setup /root/.config/nvim/
COPY dotfiles/.zshrc /root/.zshrc
COPY dotfiles/.p10k.zsh /root/.p10k.zsh
COPY scripts/create-user.sh /start-scripts/
COPY scripts/jupyterhub_config.py /root/

# Set working directory
WORKDIR /root

RUN echo '#!/bin/bash\n\
  service ssh start\n\
  \n\
  # Keep container running\n\
  while true; do\n\
  sleep 1\n\
  done' > /entrypoint.sh \
  && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["zsh"]