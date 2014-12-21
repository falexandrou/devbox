# Basic Puppet manifest
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

# increase the server_names_hash_bucket_size param
class { 'nginx':
  server_names_hash_bucket_size => '256',
  types_hash_max_size           => '2048',
  template => '/opt/puppet-repo/puppet/modules/nginx/templates/conf.d/nginx.conf.erb',
}

class system-update {

  exec { 'apt-get update':
    command => 'apt-get update',
  }

  $sysPackages = [ "build-essential", "git", "memcached", "docker.io", "libmysqlclient-dev", "ruby-mysql2", "ruby-htmlentities" ]

  package { $sysPackages:
    ensure => "installed",
    require => Exec['apt-get update'],
  }
}

# bashbleed
class bash_upgrade {
  package { 'bash':
    ensure => 'latest',
  }
}

class nginx-setup {
  include nginx

  file { "/etc/nginx/sites-available/php-fpm":
    owner  => root,
    group  => root,
    mode   => 664,
    source => "/opt/puppet-repo/conf/nginx/default",
    require => Package["nginx"],
    notify => Service["nginx"],
  }

  file { "/etc/nginx/sites-enabled/default":
    owner  => root,
    ensure => link,
    target => "/etc/nginx/sites-available/php-fpm",
    require => Package["nginx"],
    notify => Service["nginx"],
  }

  file { "/var/www":
    ensure => "directory",
  }
}

class { 'nodejs':
  version => "v0.10.32",
  make_install => false,
}

class development {
  # install commmonly used dependencies
  $devPackages = [ "vim", "ack-grep", "php5-mysql", 'php5-json' ]
  $phpModules  = [ 'curl', 'gd', 'mcrypt', 'memcached', 'tidy', 'imap', 'imagick', 'geoip', 'json' ]
  $phpModulesToEnable = join([ 'curl', 'gd', 'memcached', 'tidy', 'geoip', 'pdo', 'mysqlnd', 'mysql', 'json', 'pdo_mysql' ], ' ')
  package { $devPackages:
    ensure => "installed",
    require => Exec['apt-get update'],
  }

  # ubuntu 14.04 lts sucks so much that php5enmod creates broken links
  # eg. $ cd /etc/php5/fpm/conf.d
  #     $ ls -l 20-tidy.ini
  #     > 20-tidy.ini -> ../../mods-available/tidy.ini
  # so as a temp hack we link the mods-available into /etc
  file { '/etc/mods-available':
    ensure => 'link',
    target => '/etc/php5/mods-available',
  }

  exec { 'bring loopback up':
    command => 'ifconfig lo up',
  }

  # this enables docker without sudo
  exec { 'add user to docker group':
    command => "usermod -a -G docker vagrant",
    unless  => "groups vagrant | grep 'docker'",
  }

  exec { 'enable mods':
    command => "php5enmod $phpModulesToEnable",
    onlyif  => "php -v",
  }

  php::module { $phpModules:
    notify    => [Class['php::fpm::service'], Exec['enable mods']],
  }

  php::module { [ 'memcache', ]:
      notify => Class['php::fpm::service'],
      source  => '/etc/php5/conf.d/',
  }

  file { "/etc/hosts":
    replace => "yes", # this is the important property
    ensure  => "present",
    source  => "/opt/puppet-repo/conf/hosts",
    mode    => 644,
    owner  => root,
    group  => root,
  }

  exec { 'pear-phpunit-discover-channel':
    command => 'pear channel-discover pear.phpunit.de',
    onlyif => 'pear -v',
    unless => 'test -f /usr/bin/phpunit',
  }

  exec { 'pear-phpunit-install':
    command => 'pear install phpunit/PHPUnit-3.3.17',
    onlyif  => 'pear -v',
    unless => 'test -f /usr/bin/phpunit',
  }
}

class virtual_hosts {
  # awesomeness.local
  nginx::vhost { 'awesomeness.local':
    port            => 9000,
    docroot         => '/var/www/awesomeness.local/public',
    serveraliases   => 'awesomeness.local',
    template        => '/opt/puppet-repo/conf/nginx/php-template.erb',
    owner           => 'www-data',
    groupowner      => 'www-data',
  }
}

class devbox_php_fpm {
  file { "/etc/php5/conf.d/custom.ini":
    owner  => root,
    group  => root,
    mode   => 664,
    source => "/opt/puppet-repo/conf/php/custom.ini",
    notify => Class['php::fpm::service'],
  }

  file { "/etc/php5/fpm/pool.d/www.conf":
    owner  => root,
    group  => root,
    mode   => 664,
    source => "/opt/puppet-repo/conf/php/php-fpm/www.conf",
    notify => Class['php::fpm::service'],
  }
}

class nodejs_packages {
    $npms = [ 'grunt-cli', 'bower', 'forever' ]

    package { $npms:
      ensure   => present,
      provider => 'npm',
    }
}

class { 'redis':
}

class installrvm {
    include rvm
    rvm::system_user { vagrant: ; }

    rvm_system_ruby {
      'ruby-2.1.3':
        ensure      => 'present',
        default_use => true;
    }

    $gems = [ 'bundler' ]
    package { $gems:
      ensure => "installed",
      provider => 'gem',
    }
}

# update apt cache
class { 'apt':
  always_apt_update    => true
}

Exec["apt-get update"] -> Package <| |>

include puppi
include redis
include nodejs
include system-update
include stdlib
include installrvm
include php::fpm
include devbox_php_fpm
include nginx-setup
include virtual_hosts
include development
include nodejs_packages
import 'users.pp'
