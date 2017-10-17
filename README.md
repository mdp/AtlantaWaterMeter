# Raspberry Pi tracker for Neptune R900 smart water meters
### Works for City of Atlanta and many other municipalities

[See it in action](https://docs.google.com/spreadsheets/d/11XcyeYHD8ZzQEbY5s6f08xd5yaaU0FqFmQ8fDXtR44w/edit?usp=sharing) (Please don't judge me by my water usage)

## Introduction

Unfortunately this is less elegant and more technically verbose than I would like, but it's still the only way I've found to reliably track my water usage. I've been using this to track my water usage for over a year without any problems (although I've just recently switched for Google Spreadsheets for logging)

The goals of this project are:
- Use a Raspberry Pi and a RTL-SDR to track my smart water meter (Read: cheap, less than $50)
- Docker to simplify the installation and setup of RTLAMR
- Resin.io to deploy this docker container to the Raspberry Pi in my house
- Logging to a Google Spreadsheet so house members can track usage

## Credit

- @besmasher - Built the excellent [RTLAMR](https://github.com/bemasher/rtlamr) library which actually does all the work of reading the meters.
- [Frederik Granna's](https://bitbucket.org/fgranna/) docker base for setting up RTL-SDR on the Raspberry Pi

## Requirements

- Raspberry Pi 3 (Might work on others, only tested on the 3)
- [RTL-SDR](https://www.amazon.com/NooElec-NESDR-Mini-Compatible-Packages/dp/B009U7WZCA)
- [Resin.io](https://resin.io) for deployment and installation to the Raspberry pi

## Installation

- Signup for [Resin.io](https://resin.io)
- Create a new Application and download the image for the Raspberry Pi
- Install the image on the Raspberry Pi
- Plug in your RTL-SDR into the USB port on the Raspberry Pi
- git push this repository to your Resin application
- SSH into your Raspberry Pi via Resin and start 'rtlamr' to find water meters in your area
- In Resin, view the logs on your device and find your meter ID. This is hardest part. You'll need to know your current reading to match it up to the meter ID. I've not found any corrolation between what's written on the meter and the ID being sent out over the air.
- Once you find your meter, enter it as an environment variable in the Resin dashboard under "METERID"
- At this point it's up to you as to where you want to 'send' the data. I log to a Google Spreadsheet and have provided instructions at the end of this README

## Logging to Google Spreadsheet

I'd love to find a better alternative to this, but at the moment, it's the easiest way to track my water usage for free.

Quick overview of the script: Google has the option of writing scripts for their spreadsheets, similar to how Visual Basic was integrated into Excel. These scripts can not only modify the spreadsheet, but they can also be called via HTTP. In this case, we deploy a script that allows us to call it from the Raspberry Pi and pass over the current meter reading.

Couple of problems needed to be solved:
- At some point we'll run out of space on the spreadsheet. I solved this by setting a maximum number of rows (5000 right now). After the 5000th row, we add a row and at the same time delete the 2nd row from the top. This keep several months of history for most uses.
- We should ignore updates that are the same meter reading. For my use, it doesn't make just sense to have 50 updates overnight with the same reading. Therefore, the script will only update when the meter reading differs from the previous reading.

Sorry, this isn't an elegant solution, but it works.

1. Open my [template spreadsheet](https://docs.google.com/spreadsheets/d/11XcyeYHD8ZzQEbY5s6f08xd5yaaU0FqFmQ8fDXtR44w/edit?usp=sharing) and make a copy - 'File' > 'Make a copy...'
1. Your new copy will open. Click 'Tools' > 'Script editor'
1. In the script editor page, Change the 'SheetID' to your version of the spreadsheet
  - eg. https://docs.google.com/spreadsheets/d/158hDszrPBudHZkFik2AvQDFTDfzV8mYHq80PyHb4dDo/edit#gid=0 - the SheetId would be '158hDszrPBudHZkFik2AvQDFTDfzV8mYHq80PyHb4dDo'
1. 'File' > 'Save'
1. 'Publish' > 'Deploy as web app...' - Deploy with the following settings
  - Version: 'New'
  - Execute the app as: 'Me'
  - Who has access to the app: 'Anyone, even anonymous'
  - Click 'Deploy'
  - Authoration required prompt will display
  - Click 'Review Permissions'
  - Choose your account and allow access to your Drive
    - There might be some scary messaging here from Google about allowing an unverified script to have access to your account, but the only script that has access is the one you're looking at.
  - ** Copy the 'Current web app URL:' on the final step after clicking deploy **
1. The URL from the last step is now your URL you'll need to setup in Resin
  - Should look like `https://script.google.com/macros/u/1/s/RandomLookingScriptID]/exec`
  - In Resin add the environment variable CURL_API with the value "https://script.google.com/macros/s/RandomLookingScriptID/exec?value="
  - To test it you can send some data with 'curl: `curl -L https://script.google.com/macros/u/1/s/RandomLookingScriptID/exec?value=10`

