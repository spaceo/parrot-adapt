class oci8 {
  file {
    "/home/vagrant/oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm":
      ensure => present,
      source => "puppet:///modules/oci8/oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm";
    "/home/vagrant/oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm":
      ensure => present,
      source => "puppet:///modules/oci8/oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm";
    "/home/vagrant/answer-pecl-oci8.txt":
      ensure => present,
      source => "puppet:///modules/oci8/answer-pecl-oci8.txt";
  }

  package { ["alien", "bc", "libaio1", "unixodbc", "rlwrap"]:
    ensure => installed;
  }

  exec {
  "alien basic":
    command => "/usr/bin/alien --to-deb --scripts oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm",
    cwd => "/home/vagrant",
    require => Package["alien"],
    creates => "/home/vagrant/oracle-instantclient11.2-basic_11.2.0.3.0-2_amd64.deb",
    timeout => 3600,
    unless => "/usr/bin/test -f /home/vagrant/oracle-instantclient11.2-basic_11.2.0.3.0-2_amd64.deb";
  "alien devel":
      command => "/usr/bin/alien --to-deb --scripts oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm",
      cwd => "/home/vagrant",
      require => [Package["alien"], Exec["alien basic"]],
      creates => "/home/vagrant/oracle-instantclient11.2-devel_11.2.0.3.0-2_amd64.deb",
      timeout => 3600,
      unless => "/usr/bin/test -f /home/vagrant/oracle-instantclient11.2-devel_11.2.0.3.0-2_amd64.deb";
  }

  package {
    "oracle-instant-client-basic":
      provider => "dpkg",
      ensure => latest,
      require => [Exec["alien basic"]],
      source => "/home/vagrant/oracle-instantclient11.2-basic_11.2.0.3.0-2_amd64.deb";
    "oracle-instant-client-devel":
      provider => "dpkg",
      ensure => latest,
      require => [Exec["alien devel"]],
      source => "/home/vagrant/oracle-instantclient11.2-devel_11.2.0.3.0-2_amd64.deb";
  }

  exec { "pecl-install-oci8":
    command => "sudo pecl install oci8 < /home/vagrant/answer-pecl-oci8.txt",
    path => "/usr/bin",
    #user => root,
    timeout => 0,
    tries   => 5,
    require => [
      Package["oracle-instant-client-basic"],
      Package["oracle-instant-client-devel"],
      Package["php5-dev"],
      File["/home/vagrant/answer-pecl-oci8.txt"]
    ],
    unless => "/usr/bin/php -me | /bin/grep oci8";
  }

  file_line { "add-oci8-php" :
    path => "/etc/php5/apache2/php.ini",
    line => "extension=oci8.so",
    ensure => present,
    require => Exec["pecl-install-oci8"];
  }

  file_line { "add-oci8-php-cli" :
    path => "/etc/php5/cli/php.ini",
    line => "extension=oci8.so",
    ensure => present,
    require => Exec["pecl-install-oci8"];
  }

  file_line { "env-oracle" :
    path => "/etc/environment",
    line => "\nexport ORACLE_HOME=/usr/lib/oracle/11.2/client64/lib\nexport NLS_DATE_FORMAT=\"DD/MM/YYYY HH24:MI\"",
    ensure => present,
    require => File_line["add-oci8-php"];
  }

}
