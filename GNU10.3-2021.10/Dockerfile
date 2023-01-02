FROM ubuntu:22.04

ARG USER=builder

RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    udev \
    wget \      
    nano \
    atool \
    sudo \
    git \
    ninja-build \
    pkg-config \
    catch2 \
    libncurses5 \
    iputils-ping \
    net-tools

RUN useradd -m ${USER} && echo "${USER}:${USER}" | chpasswd && adduser ${USER} sudo

ARG INSTALL_ROOT=/opt

##################### 
# ARM Cross toolchain
#####################

# get 10.2.2021.10
ARG ARM_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10
ARG ARM_INSTALLER_EXT=tar.bz2
ARG ARM_INSTALL_DIR=gcc-arm-none-eabi-10.3-2021.10
ARG ARM_INSTALLER=${ARM_INSTALL_DIR}-x86_64-linux.${ARM_INSTALLER_EXT}
ARG ARM_INSTALL_PATH=${INSTALL_ROOT}/${ARM_INSTALL_DIR}/bin

RUN wget --directory-prefix /tmp ${ARM_URL}/${ARM_INSTALLER} \
    && aunpack -vf /tmp/${ARM_INSTALLER} -X ${INSTALL_ROOT} \
    && rm -rf /tmp/${ARM_INSTALLER}

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
ARG CMAKE_INSTALL_PATH=${INSTALL_ROOT}/${CMAKE_VERSION}/bin
RUN wget --directory-prefix /tmp https://github.com/Kitware/CMake/releases/download/v3.24.2/${CMAKE_INSTALLER}
RUN aunpack -vf /tmp/${CMAKE_INSTALLER} -X ${INSTALL_ROOT}

##################### 
# JLink tools
#####################
# Get the latest installer
ARG JLINK_INSTALLER=JLink_Linux_x86_64.tgz
RUN wget -P /tmp --post-data='accept_license_agreement=accepted' https://www.segger.com/downloads/jlink/${JLINK_INSTALLER}
RUN aunpack -vf /tmp/${JLINK_INSTALLER} -X ${INSTALL_ROOT}

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


####### FINISH

RUN apt-get install -y locales
RUN sed -i '/en_GB.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_GB.UTF-8  
ENV LANGUAGE en_GB:en  
ENV LC_ALL en_GB.UTF-8  

##########################################
### Setup PATH to use the installed tools 
##########################################

# We don't know the path of the latest JLink download ahead of time, 
# so find its install path based on the known pattern "JLink_Linux*"
# and modify any launch.json files (we expect this to fail if this is run without VSCode devcontainers)
RUN echo export JLINKPATH=$(find ${INSTALL_ROOT} -name JLink_Linux*) >> /home/${USER}/.bashrc
RUN echo 'for f in $(find /workspaces -name launch.json); do sed -i "s|.*serverpath.*|\t\t\t\"serverpath\": \"${JLINKPATH}\/JLinkGDBServerCLExe\",|g" $f; done' >> /home/${USER}/.bashrc

# Add Jlink to PATH as well. 
RUN echo export PATH=${ARM_INSTALL_PATH}:${CMAKE_INSTALL_PATH}:$(find ${INSTALL_ROOT} -name JLink_Linux*):'$PATH' >> /home/${USER}/.bashrc

###############
## finish setup
###############
USER ${USER}
WORKDIR /home/${USER}/

# note: if you're using VSCode devcontainers, you need to open a bash prompt on first use and use "select default profile".
CMD ["/bin/bash"]

# not require when configuring cmake extension with /home/${USER}/.local/share/CMakeTools/cmake-tools-kits.json 
# ENV CC=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-gcc \
#     CXX=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-g++ \
#     COV=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-gcov \
#     GDB=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-gdb \
#     SIZE=${INSTALL_ROOT}/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-size