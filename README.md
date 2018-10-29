# Iot.Home.Pi

**IoT Home for Raspberry Pi**

## Introduction

This project tests interaction between Home Assistant and Docker containers. Previous texts  from this series include:

- [IoT.Starter.Pi.Thing](https://github.com/josemotta/IoT.Starter.Pi.Thing "IoT Starter Pi Thing"): Embryos for Home Intelligence using Raspberry Pi with Linux, Docker & .NET Core. This project is based on a Raspberry Pi model 3B equipped with Raspbian GNU/Linux 9.1 Stretch Lite and a web service, generated almost automatically by Swagger Hub. The embryo platform includes API and UI in separated containers to boost the start phase of IoT initiatives.
- [IoT.Home.Thing](https://github.com/josemotta/IoT.Home.Thing "IoT Home Thing"): Home of Things added **Raspberry# IO** to the platform. It is a .NET/Mono IO Library for Raspberry Pi, initiative of the Raspberry# Community. First updated to .Net Standard 1.6 by Ramon Balaguer, then upgraded to .NET Core 2.1 and integrated to the IoT.Starter.Pi embryo.

Since we are building an embryo for an [IoT starter](https://github.com/josemotta/IoT.Starter), an empty MVC website has been provided until now as the seed for the user interface (UI). Now, this empty user interface will be substituted by the Home Assistant application, allowing faster and productive results immediately after the project is launched.

[Home Assistant](https://www.home-assistant.io/) is an open-source home automation platform running on Python 3. It is used to track and control all devices at home and has many utilities to help us with automation control. You can check at Home Assistant [blog](https://www.home-assistant.io/blog/) how dynamic is the community with constant updates and upgrades for the platform. We expect to interact Home Assistant with the embryo API available at the  IoT.Starter.Pi thing device.

## Generate image disk

There are many ways to install Home Assistant, since it supports many different hardware platforms. This project focus on Haspbian, a disk image  that contains all needed to run Home Assistant on a Raspberry Pi.

The Haspbian image is built with same script that generates the official Raspbian image's from the Raspberry Pi Foundation. The same tool used to create the raspberrypi.org Raspbian images was forked from `home-assistant/pi-gen` repository. The final stages were ripped off and a new stage-3 was replaced to install Home Assistant. With the exception of git , all dependencies are  handled by the build script.

For this project, this pi-gen tool was forked again from `home-assistant/pi-gen` to `josemotta/pi-gen` and a new `thing` [branch](https://github.com/josemotta/pi-gen/tree/thing) added a stage-4 to include Lirc installation and other initial setup for the IoT.Starter.Pi embryo. Please check the [run.sh](https://github.com/josemotta/pi-gen/blob/thing/stage4/01-tweaks/00-run.sh) script below, showing some useful dependencies added to the disk image.

    #!/bin/bash -e
    
    install -d "${ROOTFS_DIR}/var/run/lirc"
    install -m 666 -d "${ROOTFS_DIR}/home/pi/config"
    install -m 666 -d "${ROOTFS_DIR}/home/pi/backup"
    
    rm -f "${ROOTFS_DIR}/etc/lirc/lircd.conf.d/devinput.lircd.conf"
    
    install -m 644 files/i2c1-bcm2708.dtbo "${ROOTFS_DIR}/boot/overlays"
    
    install -m 644 files/config.txt "${ROOTFS_DIR}/boot/config.txt"
    install -m 644 files/lirc_options.conf "${ROOTFS_DIR}/etc/lirc/lirc_options.conf"
    install -m 644 files/ir-remote.conf "${ROOTFS_DIR}/etc/modprobe.d/ir-remote.conf"
    install -m 644 files/lirc24.conf "${ROOTFS_DIR}/etc/lirc/lircd.conf.d/lirc24.conf"
    install -m 644 files/lirc44.conf "${ROOTFS_DIR}/etc/lirc/lircd.conf.d/lirc44.conf"
    install -m 644 files/Samsung_BN59-00678A.conf "${ROOTFS_DIR}/etc/lirc/lircd.conf.d/Samsung_BN59-00678A.conf"
    install -m 644 files/AppConfig.json "${ROOTFS_DIR}/app"
    
    install -m 755 files/setup.sh "${ROOTFS_DIR}/home/pi/setup.sh"
    
    rm -f "${ROOTFS_DIR}/etc/default/keyboard"
    install -m 644 files/keyboard "${ROOTFS_DIR}/etc/default/keyboard"
    
    cat << EOF >> ${ROOTFS_DIR}/etc/samba/smb.conf
    [config]
    path = /home/pi/config
    available = yes
    valid users = pi
    read only = no
    browsable = yes
    public = yes
    writable = yes
    [backup]
    path = /home/pi/backup
    available = yes
    valid users = pi
    read only = no
    browsable = yes
    public = yes
    writable = yes
    EOF

As you can see, the stage-4 also installs and configure the Samba server to expose a couple folders:

- **/home/pi/config**: this folder is for the Home Assistant configuration
- **/home/pi/backup**: folder to backup/restore the embryo setup

After running `pi-gen` for half an hour on a virtual Debian machine, created on my development PC, a SD disk image is generated with all dependencies already installed. Ready to be inserted at Raspberry Pi drive, the image has been tested on a RPI 3B with success. Burn the image with Etcher or similar to get the heart of the embryo. Keep this SD disk for a while because we will build the project first.

## Build at fast micro

According to [IoT.Starter.Pi.Thing](https://github.com/josemotta/IoT.Starter.Pi.Thing "IoT Starter Pi Thing") strategy, build is done outside RPI, using a fast x64 micro equipped with Visual Studio and Docker using with Hyper-V machines. We moved then temporarily to the development micro with Windows 10 to build the project.

The build is ruled by `api.yml`, using docker-compose. Please see the file below:

	version: "3"
	
	services:
	  api:
	    image: josemottalopes/home-api
	    build:
	      context: .
	      dockerfile: src/IO.Swagger/api.dockerfile
	    ports:
	    - "5000:5000"
	    network_mode: bridge
	    privileged: true
	    restart: always
	    devices:
	      - /dev/mem:/dev/mem
	      - /dev/i2c-1:/dev/i2c-1
	      - /dev/gpiomem:/dev/gpiomem
	    volumes:
	      - /var/run/lirc:/var/run/lirc
	    environment:
	      - ASPNETCORE_ENVIRONMENT=Release
	
	  hass:
	    image: homeassistant/raspberrypi3-homeassistant:0.80.3
	    ports:
	      - "8123:8123"
	    network_mode: bridge
	    volumes:
	      - /home/pi/config:/config
	    restart: always
	    devices:
	      - /dev/i2c-1:/dev/i2c-1
	      - /dev/gpiomem:/dev/gpiomem
	    environment:
	      - TZ=America/Sao_Paulo
	    depends_on:
	      - mosquitto
	      - api
	
	  mosquitto:
	    build:
	      context: ./Mosquitto
	    restart: unless-stopped
	    ports:
	     - "1883:1883"
	    network_mode: bridge 
	    volumes:
	     - ./Mosquitto/auth.conf:/etc/mosquitto/conf.d/auth.conf:ro
	     - ./Mosquitto/users.passwd:/etc/mosquitto/users.passwd:ro
	
	  portainer:
	    image: portainer/portainer
	    ports:
	      - "9000:9000"
	    command: -H unix:///var/run/docker.sock
	    restart: always
	    volumes:
	      - /var/run/docker.sock:/var/run/docker.sock
	      - portainer_data:/data
	
	volumes:
	  portainer_data:

Building the solution is a long run that includes compiling the API generated by Swagger Hub and the Raspberry# IO library. The current solution also includes the UI MVC website that was used previously in this series. Below a shortcut of build session:

    jo@CANOAS24 MINGW64 /c/_git/IoT.Home.Pi/home (master)
    $ docker-compose -f api.yml build
    Building api
    Step 1/35 : FROM microsoft/dotnet:2.0.7-runtime-stretch-arm32v7 AS base
     ---> 87595eb7f1f4
    Step 2/35 : ENV DOTNET_CLI_TELEMETRY_OPTOUT 1
     ---> Using cache
     ---> 9e6c62851cc6
    Step 3/35 : ENV ASPNETCORE_URLS "http://*:5000"
     ---> Using cache
     ---> c290db537f12
    Step 4/35 : WORKDIR /app
     ---> Using cache
     ---> 7dccd40b712f
    Step 5/35 : RUN   apt-get update   && apt-get upgrade -y   && apt-get install -ylirc   --no-install-recommends &&   rm -rf /var/lib/apt/lists/*
     ---> Using cache
    
    ... big build including all projects from solution
    
      IO.Swagger -> /src/src/IO.Swagger/bin/Release/netcoreapp2.0/linux-arm/IO.Swagger.dll
      IO.Swagger -> /app/
    Removing intermediate container e98edde9e6b1
     ---> 37f4b8ed2042
    Step 32/35 : FROM base AS final
     ---> 055ee036885d
    Step 33/35 : WORKDIR /app
     ---> Using cache
     ---> 79c8c71c098b
    Step 34/35 : COPY --from=publish /app .
     ---> f0e36a46b8d2
    Step 35/35 : ENTRYPOINT ["dotnet", "IO.Swagger.dll"]
     ---> Running in 9d100e734c07
    Removing intermediate container 9d100e734c07
     ---> 46b9b656c5e2
    Successfully built 46b9b656c5e2
    Successfully tagged josemottalopes/home-api:latest
    Building mosquitto
    Step 1/3 : FROM resin/raspberry-pi-debian:stretch
     ---> ced6fc5da205
    Step 2/3 : RUN   apt-get update   && apt-get upgrade -y   && apt-get install -ymosquitto mosquitto-clients   --no-install-recommends &&   rm -rf /var/lib/apt/lists/*
     ---> Using cache
     ---> 66afe7dadb46
    Step 3/3 : CMD [ "/usr/sbin/mosquitto", "-c", "/etc/mosquitto/mosquitto.conf" ]
     ---> Using cache
     ---> d20ea9daf328
    Successfully built d20ea9daf328
    Successfully tagged home_mosquitto:latest
    hass uses an image, skipping
    portainer uses an image, skipping

Final build step should push images to Docker Hub, using docker-compose command again. See it running below:

	jo@CANOAS24 MINGW64 /c/_git/IoT.Home.Pi/home (master)
	$ docker-compose -f api.yml push
	Pushing api (josemottalopes/home-api:latest)...
	The push refers to repository [docker.io/josemottalopes/home-api]
	5b74c38596fb: Pushed
	63edb82122c7: Pushed
	08c704bc3c1a: Pushed
	bf8666defb3a: Pushed
	1f48f9c632fb: Pushed
	3ae6b6a37d49: Pushed
	0bbaa93801e6: Pushed
	28d327b91985: Pushed
	2917ff0f1d45: Pushed
	420a4cbda8df: Layer already exists
	53c3793bdb6b: Layer already exists
	002111fc932d: Layer already exists
	2e9c4696ffa4: Layer already exists
	latest: digest: sha256:779b47a4c1f9757c8abf3f137df19261e4e335c3b18cff1d16b94ddd1a92efba size: 3037

Now, we can go to RPI to deploy the embryo.

## RPI setup

The SD disk with the embryo is inserted into Raspberry Pi driver slot. The board is already equipped with an [Anavi Infrared pHat](https://www.crowdsupply.com/anavi-technology/infrared-phat), an add-on board that converts your Raspberry Pi to a smart remote control. It also supports sensor modules for temperature, humidity, barometric pressure, and light. Please check the RPI below with three sensors attached and at top left the double infrared leds that provide strong IR signals. Anavi Infrared pHat is attached through the RPI GPIO connector. Raspberry Pi also has 5V power and is connected to a Internet router by the RJ-45 network cable.

![](https://i.imgur.com/FTP6UVU.png)

On the very first run the file system is initialized. After boot, we should login to the Raspberry Pi for the first time and change the initial password for `pi` user. Please note it was kept "raspberry", the same from raspberrypi.org Raspbian image. Since SSH is available, it is possible to use the headless RPI, opening a bash terminal from another micro computer. Otherwise, just plug the USB keyboard and HDMI connectors to interact directly with the embryo. 

### Clone the repo

Next step is cloning the `Iot.Home.Pi` repository locally at Raspberry Pi. Thanks to the modified pi-gen, there should be already a script for that at pi default folder. Check below the pi user at `copa`, the chosen hostname for this embryo.

    pi@copa:~ $ cat setup.sh
    #!/bin/sh
    set -e
    
    # Home Setup
    REPO="https://github.com/josemotta/IoT.Home.Pi.git"
    HOME="/home/pi/IoT.Home.Pi"
    
    git clone $REPO $HOME

Then, staying at default `/home/pi` folder, and you just need to run:

    ./setup.sh

The folder `~/IoT.Home.Pi/home` contains the essential files for the embryo project.

    pi@copa:~ $ cd I*/home
    pi@copa:~/IoT.Home.Pi/home $ ls -l
    total 60
    -rw-r--r--  1 pi pi 1017 Oct  6 20:10 api.yml
    -rw-r--r--  1 pi pi  257 Oct  6 20:10 _clear.bat
    drwxr-xr-x  3 pi pi 4096 Oct  6 20:10 Docker
    -rw-r--r--  1 pi pi 1385 Oct  6 20:10 docker-compose.dcproj
    -rw-r--r--  1 pi pi  458 Oct  6 20:10 docker-compose.yml
    drwxr-xr-x  2 pi pi 4096 Oct  6 20:38 Hass
    -rw-r--r--  1 pi pi 1490 Oct  6 20:10 home-api.yml
    -rw-r--r--  1 pi pi  905 Oct  6 20:10 home-compose.yml
    -rw-r--r--  1 pi pi 5870 Oct  6 20:10 Home.sln
    drwxr-xr-x  4 pi pi 4096 Oct  6 20:10 Lirc
    -rw-r--r--  1 pi pi  579 Oct  6 20:10 NuGet.Config
    drwxr-xr-x  3 pi pi 4096 Oct  6 20:10 Proxy
    drwxr-xr-x  2 pi pi 4096 Oct  6 20:10 Raspberry.IO
    drwxr-xr-x 11 pi pi 4096 Oct  6 20:10 src
    pi@copa:~/IoT.Home.Pi/home $
