# Vagrant Craft 3

Starter Craft CMS 3 setup using Vagrant for local development. Initial starter site url is http://localhost:8378. Depending on network environment the site will be accessible to other devices via [http://COMPUTER_NAME:8378](http://COMPUTER_NAME:8378).

Vagrant settings support macOS and Windows. Virtual machine is running Ubuntu 16 with PHP 7.0. Port number can be changed as desired in the Vagrantfile.

## Instructions

1. Clone/download repository
2. Change the main folder name to your project
2. Run `vagrant up`
3. Go to http://localhost:8378/index.php?p=admin to finalize Craft installation
   1. Enter database information, Password=**password** and Datbase Name=**craft**
   2. Create first admin account
   3. Enter site details, *clear out the http://localhost reference and leave blank*

*\*Note: If cloned the .gitignore and .git files will need to be replaced.*

## Requirements
- [Vagrant](https://www.vagrantup.com/)
- [Virtual Box](https://www.virtualbox.org/)
