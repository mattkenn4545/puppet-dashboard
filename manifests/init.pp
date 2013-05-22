class puppet-dashboard ( $db_password ) {
  package { 'puppet-dashboard':
    ensure => 'installed',
  }

  class { 'mysql::server':
    config_hash => {
      'root_password' => $db_password
    }
  }

  file { 'settings.yml':
    mode    => '0640',
    owner   => 'www-data',
    group   => 'www-data',
    source  => "puppet:///modules/${module_name}/settings.yml",
    path    => "/etc/puppet-dashboard/settings.yml",
    require => Package[ 'puppet-dashboard' ]
  }

  file { 'database.yml':
    mode    => '0640',
    owner   => 'www-data',
    group   => 'www-data',
    content => template("${module_name}/database.yml.erb"),
    path    => "/etc/puppet-dashboard/database.yml",
    require => Package[ 'puppet-dashboard' ]
  }
}
