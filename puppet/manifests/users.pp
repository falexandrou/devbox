# mysql root password
class { "mysql":
  root_password => 'qwerty1',
}

include mysql
