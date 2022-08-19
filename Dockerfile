FROM ubuntu:20.04

ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y \
    curl \
    git \
    unzip \ 
    xz-utils \
    zip \
    libglu1-mesa \
    libgtk-3-dev \
    openjdk-8-jdk \
    wget \
    clang \
    cmake \
    ninja-build \
    pkg-config
RUN useradd -ms /bin/bash user && usermod -aG sudo user
USER user
WORKDIR /home/user

#Installing Android SDK
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/user/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29" "cmdline-tools;latest"
ENV PATH "$PATH:/home/user/Android/sdk/platform-tools"

#Installing Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/user/flutter/bin"
RUN flutter channel stable
RUN flutter upgrade
RUN flutter doctor

#Fetching App
RUN git clone https://github.com/abhi16180/photon.git
WORKDIR /home/user/photon