# Iot.Home.Pi

**IoT Home for Raspberry Pi**

## Introduction

This post tests interaction between Home Assistant and Docker containers. Previous posts from this series include:

- [IoT.Starter.Pi.Thing](https://github.com/josemotta/IoT.Starter.Pi.Thing "IoT Starter Pi Thing"): Embryos for Home Intelligence using Raspberry Pi with Linux, Docker & .NET Core. At this post, we have a Raspberry Pi model 3B equipped with Raspbian GNU/Linux 9.1 Stretch Lite and a web service, generated almost automatically by Swagger Hub. The embryo platform includes API and UI in separated containers to boost the start phase of IoT initiatives.
- [IoT.Home.Thing](https://github.com/josemotta/IoT.Home.Thing "IoT Home Thing"): Home of Things added **Raspberry# IO** to the platform. It is a .NET/Mono IO Library for Raspberry Pi, initiative of the Raspberry# Community. First updated to .Net Standard 1.6 by Ramon Balaguer, then upgraded to .NET Core 2.1 and integrated to the IoT.Starter.Pi embryo.

Since we are building an embryo for a [IoT starter](https://github.com/josemotta/IoT.Starter), an empty MVC website has been provided until now as the seed for the user interface (UI). At this post, this empty user interface will be substituted by the Home Assistant application, allowing faster and productive results immediately after the project is launched.

[Home Assistant](https://www.home-assistant.io/) is an open-source home automation platform running on Python 3. It is used to track and control all devices at home and has many utilities to help us with automate control. You can check at Home Assistant [blog](https://www.home-assistant.io/blog/) how dynamic is the community with constant updates and upgrades for the platform. We expect to interact Home Assistant with the embryo API available at the  IoT.Starter.Pi thing device.

## Generate image disk

There are many ways to install Home Assistant, since it supports many different hardware platforms. This post focus on Haspbian, a disk image  that contains all needed to run Home Assistant on a Raspberry Pi.

The Haspbian image is built with same script that generates the official Raspbian image's from the Raspberry Pi Foundation. The same tool used to create the raspberrypi.org Raspbian images was forked from `home-assistant/pi-gen` repository. The final stages were ripped off and a new stage-3 was replaced to install Home Assistant. With the exception of git , all dependencies are  handled by the build script.

For this project, this pi-gen tool was forked again to `josemotta/pi-gen` and a new `thing` [branch](https://github.com/josemotta/pi-gen/tree/thing) added an extra stage-4 to include Lirc installation and other initial demo setup for the IoT.Starter.Pi embryo.

The extra stage-4 also installs Samba server to expose a couple folders:

- **/home/pi/config**: this folder is for the Home Assistant configuration
- **/home/pi/backup**: folder to backup/restore the embryo setup

After running pi-gen for half an hour, a SD disk image is generated with all dependencies already installed, and ready to be inserted at Raspberry Pi drive. This image has been tested on a RPI 3B with success. Burn image with Etcher or similar to get the heart of the embryo.

## RPI setup

The SD disk with the embryo is inserted at a Raspberry Pi equipped with [Anavi Infrared pHat](https://www.crowdsupply.com/anavi-technology/infrared-phat) an add-on board that converts your Raspberry Pi to a smart remote control. It also supports sensor modules for temperature, humidity, barometric pressure, and light. Please check the RPI below with three sensors attached and at left the double infrared leds. Anavi Infrared pHat is attached to RPI GPIO connector. Raspberry Pi also has 5V power and RJ-45 Ethernet connected to an Internet router.

![](https://i.imgur.com/FTP6UVU.png)

On the very first run the file system is initialized. After boot, we should login to the Raspberry Pi for the first time and change the initial password for `pi` user. Please note it was kept "raspberry", the same from raspberrypi.org Raspbian image. Since SSH is available, it is possible to use the headless RPI, opening a terminal window. Otherwise, just plug an USB keyboard and HDMI connector to interact directly with the embryo. 

### Clone repo

In order to develop this project, next step is to clone the `Iot.Home.Pi` repository locally at Raspberry Pi. There should be already a script for that at `/home/pi` folder, you just need to run:

    ./setup.sh

