#---------------------------------------------------------------------------------------------------------------------------
#----
#----   Start base image
#----
#---------------------------------------------------------------------------------------------------------------------------

FROM ros:humble-ros-core-jammy as base

## Parameters
ENV ASTRA_ROOT=/astra

#############################################################################################################################
#####
#####   Install Dependencies
#####
#############################################################################################################################

WORKDIR /

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends ros-dev-tools \
                                               libgflags-dev \
                                               nlohmann-json3-dev \
                                               libusb-1.0-0-dev \
                                               ros-$ROS_DISTRO-tf2-eigen \
                                               ros-$ROS_DISTRO-image-transport \
                                               ros-$ROS_DISTRO-image-publisher \
                                               ros-$ROS_DISTRO-camera-info-manager \
                                               udev

RUN apt-get clean

#############################################################################################################################
#####
#####   Install dependency packages
#####
#############################################################################################################################

WORKDIR /SDK

RUN wget -c https://github.com/google/glog/archive/refs/tags/v0.6.0.tar.gz  -O glog-0.6.0.tar.gz && \
    tar -xzvf glog-0.6.0.tar.gz  && \
    cd glog-0.6.0  && \
    mkdir build && \
    cd build  && \
    cmake .. && \
    make  && \
    make install  && \
    ldconfig 

RUN wget -c https://github.com/Neargye/magic_enum/archive/refs/tags/v0.8.0.tar.gz -O  magic_enum-0.8.0.tar.gz && \
    tar -xzvf magic_enum-0.8.0.tar.gz && \
    cd magic_enum-0.8.0 && \
    mkdir build  && \
    cd build  && \
    cmake .. && \
    make  && \
    make install  && \
    ldconfig

RUN git clone https://github.com/libuvc/libuvc.git && \
    cd libuvc && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    ldconfig

#############################################################################################################################
#####
#####   Install Astra legacy packages
#####
#############################################################################################################################

WORKDIR ${ASTRA_ROOT}/src

RUN git clone https://github.com/AIResearchLab/astra_legacy_ros.git

RUN rosdep init && rosdep update && rosdep install --from-paths ${ASTRA_ROOT}/src -y --ignore-src

#############################################################################################################################
#####
#####   Build Kobuki packages
#####
#############################################################################################################################

WORKDIR ${ASTRA_ROOT}

RUN . /opt/ros/humble/setup.sh && colcon build

WORKDIR /

#############################################################################################################################
#####
#####   Remove workspace source and build files that are not relevent to running the system
#####
#############################################################################################################################

RUN rm -rf /SDK
RUN rm -rf ${ASTRA_ROOT}/src
RUN rm -rf ${ASTRA_ROOT}/log
RUN rm -rf ${ASTRA_ROOT}/build

RUN apt-get purge --yes libgflags-dev \
                        nlohmann-json3-dev \
                        libusb-1.0-0-dev

RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/*
RUN apt-get clean


#---------------------------------------------------------------------------------------------------------------------------
#----
#----   Start final release image
#----
#---------------------------------------------------------------------------------------------------------------------------


FROM ros:humble-ros-core-jammy as final

## Parameters
ENV ASTRA_ROOT=/astra

WORKDIR /

COPY --from=base / /

RUN wget https://raw.githubusercontent.com/AIResearchLab/astra_legacy_ros/main/astra_camera/scripts/56-orbbec-usb.rules && \
    cp 56-orbbec-usb.rules /etc/udev/rules.d/56-orbbec-usb.rules && \
    service udev reload && \
    service udev restart

COPY workspace_entrypoint.sh /workspace_entrypoint.sh

RUN chmod +x /workspace_entrypoint.sh

ENTRYPOINT [ "/workspace_entrypoint.sh" ]

WORKDIR ${ASTRA_ROOT}