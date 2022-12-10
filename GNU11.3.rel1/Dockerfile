FROM ubuntu:22.04

ARG USER=builder

RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    wget \   
    nano \   
    atool \
    sudo \
    git \
    ninja-build \
    pkg-config \
    catch2

RUN useradd -m $USER && echo "$USER:$USER" | chpasswd && adduser $USER sudo

##################### 
# ARM Cross toolchain
#####################

# # get 11.3.rel1
ARG ARM_URL=https://developer.arm.com/-/media/Files/downloads/gnu/11.3.rel1/binrel
ARG ARM_INSTALLER=arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi.tar.xz

# ARG ARM_INSTALLER_EXT=tar.xz
# ARG ARM_INSTALL_DIR=gcc-arm-none-eabi-10.3-2021.10
# ARG ARM_INSTALLER=${ARM_INSTALL_DIR}-x86_64-linux.${ARM_INSTALLER_EXT}
# ARG ARM_INSTALL_PATH=${INSTALL_ROOT}/${ARM_INSTALL_DIR}/bin

RUN wget --directory-prefix /tmp $ARM_URL/$ARM_INSTALLER \
    && aunpack -vf /tmp/$ARM_INSTALLER -X /opt \
    && rm /tmp/$ARM_INSTALLER

# configure cmake kits
RUN mkdir -p -m 777 /home/${USER}/.local/share/CMakeTools && \
    echo '\
    [\n\
    \t{\n\
    \t\t"name": "GCC 10.3.1 arm-none-eabi",\n\
    \t\t"compilers": {\n\
    \t\t\t"C": "'${ARM_INSTALL_PATH}'/arm-none-eabi-gcc",\n\
    \t\t\t"CXX": "'${ARM_INSTALL_PATH}'/arm-none-eabi-g++"\n\
    \t\t}\n\
    \t}\n\
    ]\n\
    ' > /home/${USER}/.local/share/CMakeTools/cmake-tools-kits.json



##################### 
# CMake
####################
ARG CMAKE_VERSION=cmake-3.24.2-linux-x86_64
ARG CMAKE_INSTALLER=${CMAKE_VERSION}.tar.gz
ARG CMAKE_INSTALL_PATH=/opt/${CMAKE_VERSION}/bin
RUN wget --directory-prefix /tmp https://github.com/Kitware/CMake/releases/download/v3.24.2/$CMAKE_INSTALLER
RUN aunpack -vf /tmp/$CMAKE_INSTALLER -X /opt


##################### 
# JLink tools
#####################
ARG JLINK_INSTALLER=JLink_Linux_x86_64.tgz
ARG JLINK_DIR=JLink_Linux_V782_x86_64
RUN wget -P /tmp --post-data='accept_license_agreement=accepted' https://www.segger.com/downloads/jlink/${JLINK_INSTALLER}
RUN aunpack -vf /tmp/${JLINK_INSTALLER} -X /opt
# runtime deps - note these are all X-related libs
RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    libfreetype6 \
    libsm6 \
    libxrender1 \
    libxrandr2 \
    libxfixes3 \
    libxcursor1 \
    libfontconfig1

######################
# Catch2
######################
# RUN git clone https://github.com/catchorg/Catch2.git \
#     && cd Catch2 \
#     && ${CMAKE_INSTALL_PATH}/cmake -D"CMAKE_MAKE_PROGRAM:PATH=/usr/bin/ninja" -Bbuild -H. -DBUILD_TESTING=OFF \
#     && ${CMAKE_INSTALL_PATH}/cmake -D"CMAKE_MAKE_PROGRAM:PATH=/usr/bin/ninja" --build build/ --target install

# ##################### 
# # VSCode
# #####################
# # fetch vscode

# ##################### 
# # STM32CubeIDE
# #####################
# # fetch STM32CubeIDE

# Setup PATH to use the installed tools
RUN echo export PATH=/opt/${ARM_INSTALLER%.tar.xz}/bin:${CMAKE_INSTALL_PATH}:/opt/${JLINK_DIR}:$PATH >> /home/$USER/.bashrc

USER $USER
# RUN git clone https://github.com/cracked-machine/BassStationSequencerSW.git --recursive ~/project
WORKDIR /home/$USER/
CMD /bin/bash

ENV CC=/opt/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gcc \
    CXX=/opt/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-g++ \
    COV=/opt/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gcov \
    GDB=/opt/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gdb \
    SIZE=/opt/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-size

