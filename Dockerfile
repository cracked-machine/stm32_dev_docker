# FIXME: Doesn't work with Ubuntu 22.04. GDB 11 and higher requires python3.8, ubuntu 22.04 has python3.10 available only.
FROM ubuntu:20.04

ARG ARM_URL
ARG CMAKE_URL
ARG JLINK_URL

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
    # catch2 \
    libncurses5 \
    libncursesw5 \
    python3 \
    python3-pip \
    iputils-ping \
    net-tools 

RUN useradd -m $USER && echo "$USER:$USER" | chpasswd && adduser $USER sudo

ENV INSTALL_ROOT=/opt

##################### 
# ARM Cross toolchain
#####################

# download and install
RUN wget --directory-prefix /tmp ${ARM_URL} \
    && aunpack -vf /tmp/$(basename "$ARM_URL") -X ${INSTALL_ROOT} \
    && rm -rf /tmp/$(basename "$ARM_URL")

# configure cmake kits. Remove the file extensions keep only the base names
RUN mkdir -p -m 777 /home/${USER}/.local/share/CMakeTools && \
    echo '\
    [\n\
    \t{\n\
    \t\t"name": "GCC '$(find ${INSTALL_ROOT} -name *arm-* | head -n 1)' ",\n\
    \t\t"compilers": {\n\
    \t\t\t"C": "'$(find ${INSTALL_ROOT} -name *arm-* | head -n 1)'/bin/arm-none-eabi-gcc",\n\
    \t\t\t"CXX": "'$(find ${INSTALL_ROOT} -name *arm-* | head -n 1)'/bin/arm-none-eabi-g++"\n\
    \t\t}\n\
    \t}\n\
    ]\n\
    ' > /home/${USER}/.local/share/CMakeTools/cmake-tools-kits.json

RUN chmod 777 /home/${USER}/.local/share/CMakeTools/cmake-tools-kits.json

##################### 
# CMake
####################
RUN wget --directory-prefix /tmp ${CMAKE_URL} \
    && aunpack -vf /tmp/$(basename ${CMAKE_URL}) -X /opt


##################### 
# JLink tools
#####################
RUN wget -P /tmp --post-data='accept_license_agreement=accepted' ${JLINK_URL} \
    && aunpack -vf /tmp/$(basename ${JLINK_URL}) -X /opt
# runtime deps - note these are all X-related libs
RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    libfreetype6 \
    libsm6 \
    libxrender1 \
    libxrandr2 \
    libxfixes3 \
    libxcursor1 \
    libfontconfig1 \
    usbutils

######################
# Catch2
######################
# RUN git clone https://github.com/catchorg/Catch2.git \
#     && cd Catch2 \
#     && ${CMAKE_INSTALL_PATH}/cmake -D"CMAKE_MAKE_PROGRAM:PATH=/usr/bin/ninja" -Bbuild -H. -DBUILD_TESTING=OFF \
#     && ${CMAKE_INSTALL_PATH}/cmake -D"CMAKE_MAKE_PROGRAM:PATH=/usr/bin/ninja" --build build/ --target install

##########################################
### Setup PATH to use the installed tools 
##########################################

# Remove the file extensions keep only the base names
# note JLINK_URL ends with .tgz not .tar.gz
RUN echo \
    '\nexport JLINKPATH='$(find ${INSTALL_ROOT} -name JLink_Linux*)'\
    \nexport ARMPATH='$(find ${INSTALL_ROOT} -name *arm-* | head -n 1)'/bin\
    \nexport CMAKEPATH='${INSTALL_ROOT}/$(basename "${CMAKE_URL%.*.*}")'/bin\
    \nif [ -d /workspaces ] \nthen\
    \nfor f in $(find /workspaces -name launch.json);\
    \n\tdo sed -i "s|.*serverpath.*|\t\t\t\"serverpath\": \"${JLINKPATH}\/JLinkGDBServerCLExe\",|g" $f;\
    \ndone\
    \nfor f in $(find /workspaces -name settings.json);\
    \n\tdo sed -i "s|.*cortex-debug.armToolchainPath.*|\t\"cortex-debug.armToolchainPath\":\"${ARMPATH}\"|g" $f;\
    \ndone\nfi\
    \n\nexport PATH=${ARMPATH}:${CMAKEPATH}:${JLINKPATH}:'$PATH \
    >> /home/${USER}/.bashrc

###############
## finish setup
###############
RUN chown builder  /home/$USER/.local/. /home/$USER/.local/share
RUN echo "export PATH=$PATH:/home/builder/.local/bin" >> /home/builder/.bashrc
USER $USER
WORKDIR /home/$USER/
CMD /bin/bash

# not require when configuring cmake extension with /home/${USER}/.local/share/CMakeTools/cmake-tools-kits.json 
# ENV CC=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-gcc \
#     CXX=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-g++ \
#     COV=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-gcov \
#     GDB=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-gdb \
#     SIZE=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-size

