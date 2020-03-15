#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# [Optional] Version of Node.js to install.
ARG INSTALL_NODE="true"
ARG INSTALL_PWSH="true"
ARG PWSH_VERSION="7.0.0"
ARG INSTALL_DOCKER="true"
ARG GLIBC_VER="2.31-r0"
ENV NVM_DIR=/home/vscode/.nvm

# [Optional] Install the Azure CLI
ARG INSTALL_AZURE_CLI="false"



# Configure apt and install packages
RUN apk update \
    && ln -sf /usr/share/dotnet /usr/local/share/dotnet \
    && ln -sf /usr/bin/dotnet /usr/local/bin/dotnet \
    && apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    && apk add --no-cache --virtual=.build-dependencies ca-certificates \
    && cert-sync /etc/ssl/certs/ca-certificates.crt \
    && apk del .build-dependencies \
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apk add -q --no-cache git iproute2 procps curl wget shadow sudo gnupg libstdc++ coreutils curl bash openssh \
    # && apk add -q no-cache make automake gcc g++ libtool autoconf pkgconf linux-headers cmake krb5-libs \
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && curl -sfL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk" \
         "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk" \
         "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk" \
    && apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk glibc-i18n-${GLIBC_VER}.apk && rm *.apk \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && dotnet tool install --tool-path /home/vscode/.dotnet/tools dotnet-counters \
    && dotnet tool install --tool-path /home/vscode/.dotnet/tools dotnet-dump \
    && dotnet tool install --tool-path /home/vscode/.dotnet/tools dotnet-trace \
    # [Optional] Add sudo support for the non-root user
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # [Optional] Install Node.js for ASP.NET Core Web Applicationss
    && if [ "$INSTALL_NODE" = "true" ]; then \
    # Install Node
    # Install yarn
    apk add -q --no-cache nodejs yarn; \
    fi \
    #
    # [Optional] Install the Azure CLI
    && if [ "$INSTALL_AZURE_CLI" = "true" ]; then \
    apk add -q --no-cache py-pip \
    && apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make \
    && pip --no-cache-dir install -U pip \
    && pip --no-cache-dir install azure-cli \
    && apk del --purge build; \
    fi \
    # PowerShell
    && if [ "$INSTALL_PWSH" = "true" ]; then \
    export PWSH_VERSION=${PWSH_VERSION} \
    && apk add --no-cache lttng-ust ca-certificates less ncurses-terminfo-base krb5-libs libgcc libintl libssl1.1 libstdc++ tzdata userspace-rcu zlib icu-libs \
    && curl -L https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-alpine-x64.tar.gz -o /tmp/powershell.tar.gz \
    && mkdir -p /opt/microsoft/powershell/${PWSH_VERSION%%.*} \
    && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/${PWSH_VERSION%%.*} \
    && chmod +x /opt/microsoft/powershell/${PWSH_VERSION%%.*}/pwsh \
    && ln -sf /opt/microsoft/powershell/${PWSH_VERSION%%.*}/pwsh /usr/bin/pwsh \
    && echo "/usr/bin/pwsh" > /etc/shells \
    && userdel $USERNAME \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /usr/bin/pwsh --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && pwsh -c 'Install-Module posh-git -Scope CurrentUser -Force; Install-Module oh-my-posh -Scope CurrentUser -Force' \
    &&  mkdir -p /home/${USERNAME}/.config/powershell && mkdir -p /root/.config/powershell \
    && echo $'$env:MSBuildSDKsPath = "/usr/local/share/dotnet/sdk/" + $(dotnet --version) + "/Sdks" \n\
$env:PATH+=":/usr/local/share/dotnet:/home/vscode/.dotnet/tools" \n\
Import-Module posh-git \n\
Import-Module oh-my-posh \n\
Set-Theme Paradox'>/root/.config/powershell/Microsoft.PowerShell_profile.ps1 \
    &&  echo $'$env:MSBuildSDKsPath = "/usr/local/share/dotnet/sdk/" + $(dotnet --version) + "/Sdks" \n\
$env:PATH+=":/usr/local/share/dotnet:/home/vscode/.dotnet/tools" \n\
Import-Module posh-git \n\
Import-Module oh-my-posh \n\
Set-Theme Paradox'>/home/${USERNAME}/.config/powershell/Microsoft.PowerShell_profile.ps1 \
    && mkdir -p /home/${USERNAME}/.local/share &&cp -r /root/.local/share/powershell /home/${USERNAME}/.local/share/ \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}; \
    fi \
    && if [ "$INSTALL_DOCKER" = "true" ]; then \
    apk add -q --no-cache docker openrc \
    && usermod -aG docker ${USERNAME}; \
    fi \
    && echo "Set disable_coredump false" > /etc/sudo.conf \
    && curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l /usr/local/vsdbg -r linux-musl-x64
