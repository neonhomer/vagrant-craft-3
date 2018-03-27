# Vagrant Craft 3

Starter Craft CMS 3 setup using Vagrant for local development. Initial starter site url is http://localhost:8378. Depending on network environment the site should be accessible to other devices via [http://COMPUTER_NAME:8378](http://COMPUTER_NAME:8378).

Vagrant settings support macOS and Windows. Virtual machine is running Ubuntu 16 with PHP 7.0. Port number can be changed as desired in the Vagrantfile. 

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
   1. Enter database information, Password = **password** and Datbase Name = **craft**
   1. Create first admin account
   1. Enter site details, leaving Base URL = **@web**

*\*Note: If cloned the .gitignore and .git files will need to be replaced.*

## Changelog

**2018-03-27**

- Added Xdebug
- Added Visual Studio Code launch.json for debugging with Xdebug
- Removed custom globals URI_PORT and SITE_URL by using @web alias for siteUrl
