class puppet-dashboard ( $dashboard_password ) {
  include puppet-dashboard::vhost

  package { 'puppet-dashboard':
    ensure => 'installed',
  }

  package { ['rake', 'rdoc', 'rack' ]:
    ensure   => present,
    provider => 'gem',
  }

  mysql::db { 'dashboard':
    user     => 'dashboard',
    password => $dashboard_password,
    charset  => 'utf8',
  }

  exec { 'db-migrate':
    command => 'rake RAILS_ENV=production db:migrate',
    cwd     => '/usr/share/puppet-dashboard',
    path    => '/usr/bin/:/usr/local/bin/',
    creates => "/var/lib/mysql/dashboard/nodes.frm",
    require => [ Package[ 'puppet-dashboard' ], Mysql::Db[ 'dashboard' ], File[ 'database.yml' ] ],
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

  file { 'dashboard-production-log':
    mode    => '0666',
    content => '',
    path    => '/usr/share/puppet-dashboard/log/production.log',
  }

  ini_setting { 'enable puppet-dashboard-workers':
    ensure  => present,
    path    => '/etc/default/puppet-dashboard-workers',
    section => '',
    setting => 'START',
    value   => 'yes',
    require => Package[ 'puppet-dashboard' ],
  }
}
