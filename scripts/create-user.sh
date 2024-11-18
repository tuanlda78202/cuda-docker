#!/bin/bash
# docker-entrypoint.sh

# Function to set password for a given user
set_password() {
    local user=$1
    local password=$2
    echo "${user}:${password}" | chpasswd
}

# Check if the user is root
if [ "$MY_USER" == "root" ]; then
    if [ -n "$MY_PASSWORD" ]; then
        set_password root "$MY_PASSWORD"
    fi
    echo "cd /home/$MY_USER" >> ~/.zshrc 
else
    # Check if the user already exists
    if ! id "$MY_USER" &>/dev/null; then
        # Create the user with the specified UID and GID
        adduser --disabled-password --gecos "" --uid $MY_UID $MY_USER

        # Set the user's password
        if [ -n "$MY_PASSWORD" ]; then
            set_password "$MY_USER" "$MY_PASSWORD"
        fi
    fi

    echo "export PATH=\"/home/$MY_USER/.local/bin:\$PATH\"" >> ~/.zshrc
    cp -a /root/. /home/$MY_USER
    chown -R $MY_USER:$MY_USER /home/$MY_USER
    chsh -s /bin/zsh $MY_USER
fi
