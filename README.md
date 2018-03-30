# Vagrant Craft 3

Starter Craft CMS 3 setup using Vagrant for local development. This setup uses a special port number to allow testing the site without modifying a hosts file. The site should be accessible to other devices on the same network.

Initial site url is http://localhost:8378. Or using the local computer name like [http://COMPUTER_NAME:8378](http://COMPUTER_NAME:8378). Port number is adjustable modified in the Vagrantfile.

Vagrant settings support macOS and Windows. Virtual machine is running Ubuntu 16 with PHP 7.0. 

Installation includes Xdebug for PHP debugging and Visual Studio Code launch.json.

## Requirements

- [Vagrant](https://www.vagrantup.com/)
- [Virtual Box](https://www.virtualbox.org/)

## Instructions

1. Clone/download repository
1. Change the main folder name to your project name
	1. If desired change port number in Vagrantfile
1. Run `vagrant up`
1. Go to http://localhost:8378/admin to finalize Craft installation
   1. Create first admin account
   1. Enter site details, leaving Base URL = **@web**

**\*Note: Before starting an actual project the .gitignore and .git files will need to be replaced.**

## Changelog

**2018-03-30**

- Added PHP Intl module
- Changed PHP memory limit to 256MB
- Changed Craft setup to automatically apply database settings
- Removed temporary index file as Craft now includes one

**2018-03-27**

- Added Xdebug
- Added Visual Studio Code launch.json for debugging with Xdebug
- Removed custom globals URI_PORT and SITE_URL by using @web alias for siteUrl
