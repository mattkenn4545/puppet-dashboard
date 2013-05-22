class puppet-dashboard {
  package { 'puppet-dashboard':
    ensure => 'installed',
  }

  file { ['settings.yml', 'database.yml']:
    mode    => '0660',
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/${module_name}/${name}",
    path    => "/etc/puppet-dashboard/${name}",
    ensure  => Package['puppet-dashboard'],
  }
}