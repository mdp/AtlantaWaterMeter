# Consumption Tracker for Atlanta Smart Water Meters

Notice: This is still early in development, but working well for my use. The setup
process is not simple and requires a fair amount of knowledge about git, Resin, and the
rtl-sdr app.

## Credit

- @besmasher - Built the excellent [RTLAMR](https://github.com/bemasher/rtlamr) library which actually does all the work of reading the meters.
- [Frederik Granna's](https://bitbucket.org/fgranna/) docker base for setting up RTL-SDR on the Raspberry Pi

## Requirements

- Raspberry Pi 3 (Might work on others, only tested on the 3)
- [RTL-SDR](https://www.amazon.com/NooElec-NESDR-Mini-Compatible-Packages/dp/B009U7WZCA)
- [Resin.io](https://resin.io) for deployment and installation to the Raspberry pi
- Optional: [StatX](https://statx.io) for reporting

## Installation

- Signup for [Resin.io](https://resin.io)
- Create a new Application and download the image for the Raspberry Pi
- Install the image on the Raspberry Pi
- Plug in your RTL-SDR into the USB port on the Raspberry Pi
- git push this repository to your Resin application
- SSH into your Raspberry Pi via Resin and start 'rtlamr' to find water meters in your area
- Once you find your meter, enter it as an environment variable in the Resin dashboard until "METERID"
- Decide what you want to do with the meter readings (I use [StatX](https://statx.io) to log the readings and view them on my phone)

![StatX Screenshot](https://cloud.githubusercontent.com/assets/2868/21464808/1ad63648-c957-11e6-9be4-7c3dc1b2b307.png) ![Raspberry Pi](https://cloud.githubusercontent.com/assets/2868/21464807/14e7c1b6-c957-11e6-8049-69b19969f817.jpg)
