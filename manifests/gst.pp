node default {

# Run apt-get update when anything beneath /etc/apt/ changes
exec { "apt-update":
  command => "/usr/bin/apt-get update",
}

Exec["apt-update"] -> Package <| |>

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
