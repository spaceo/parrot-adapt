node default {

# Run apt-get update when anything beneath /etc/apt/ changes
exec { "apt-update":
  command => "/usr/bin/apt-get update",
}

Exec["apt-update"] -> Package <| |>
  # Pear/drush  
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
  # Use the "current_site" drush alias idea.
  file_line { "drush-current-site" :
    path => "/etc/bash.bashrc",
    line => sprintf("\nexport CURRENT_SITE='none'\nfunction dr {\n  drush %s $*\n}", '"@${CURRENT_SITE}"'),
    ensure => present,
    require => Exec["pear install drush"];
  }

  # Postgres 
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
  # Php oracle client
  class {'oci8': }

  # Monit
 #package { 'monit': }
}
