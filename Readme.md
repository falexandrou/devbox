Set up a PHP development box super fast
=======================================

Disclaimer
----------
This is work in progress and acts as a template and placeholder for your puppet based local environments. **not for production**

Useful
------
* MySQL root pass is ```qwerty1``` 

Installation
------------

* Install vagrant using the installation instructions in the [Getting Started document](https://docs.vagrantup.com/v2/)
* Add a Ubuntu Precise box using the [available official boxes](https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Boxes), for example: ```vagrant box add phpdevbox http://files.vagrantup.com/precise64.box```
* Clone this repository
* Install submodules with ```git submodule update --init --recursive```
* Search for ```awesomeness.local``` and replace with an actual name
* After running ```vagrant up``` the box is set up using Puppet
* Enjoy

Installed components
--------------------

* [Nginx](http://nginx.org) using puppet module (https://github.com/example42/puppet-nginx)
* [Apache](http://httpd.apache.org/) using puppet module (https://github.com/example42/puppet-apache)
* [php-fpm](http://php-fpm.org) using puppet module (https://github.com/saz/puppet-php)
* [git](http://git-scm.com/)
* [pear](http://pear.php.net/) using puppet module (https://github.com/rafaelfelix/puppet-pear)
* [Node.js](http://nodejs.org/)
* [npm](http://npmjs.org/)
* [less](http://lesscss.org/)
* [MySQL](http://dev.mysql.com/downloads/mysql/) using puppet module (https://github.com/example42/puppet-mysql)
* [Capistrano](https://github.com/capistrano/capistrano)
* [Docker](https://www.docker.com/)

TODO
----
* Use hiera
* Make it easier to add stuff without modifying the source

Based on [dirkaholic/vagrant-php-dev-box](https://github.com/falexandrou/vagrant-php-dev-box)