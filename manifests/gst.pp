node default {

# Run apt-get update when anything beneath /etc/apt/ changes
exec { "apt-update":
  command => "/usr/bin/apt-get update",
}

Exec["apt-update"] -> Package <| |>
  
  class {'pear': }
  
  exec { "pear update-channels" :
    command => "/usr/bin/pear update-channels",
    require => [Package['php-pear']]
  } 
  exec {"pear install drush":
    command => "/usr/bin/pear channel-discover pear.drush.org && /usr/bin/pear install drush/drush",
    creates => '/usr/bin/drush',
    require => Exec['pear update-channels']
  }
 
  package { 'php5-pgsql': }
 
  class { 'postgresql':
    charset => 'UTF8',
    locale  => 'en_US.UTF-8',
  }->
  class { 'postgresql::server':
    config_hash => {
      postgres_password => 'root',
    },
  }

  postgresql::db { 'gst':
    user     => 'vagrant',
    password => 'vagrant',
    grant    => 'ALL',
  }

}
