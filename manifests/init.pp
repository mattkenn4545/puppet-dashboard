class puppet-dashboard ( $dashboard_password ) {
  include puppet-dashboard::vhost

  package { ['rake', 'rdoc', 'rack' ]:
    ensure   => present,
    provider => 'gem'
  } ->
  package { 'puppet-dashboard':
    ensure  => 'installed'
  } ->

  mysql::db { 'dashboard':
    user     => 'dashboard',
    password => $dashboard_password,
    charset  => 'utf8',
  } ->

  file { 'dashboard-production-log':
    mode    => '0666',
    content => '',
    path    => '/usr/share/puppet-dashboard/log/production.log',
    replace => false
  } ->

  file { 'settings.yml':
    mode    => '0640',
    owner   => 'www-data',
    group   => 'www-data',
    source  => "puppet:///modules/${module_name}/settings.yml",
    path    => "/etc/puppet-dashboard/settings.yml"
  } ->

  file { 'database.yml':
    mode    => '0640',
    owner   => 'www-data',
    group   => 'www-data',
    content => template("${module_name}/database.yml.erb"),
    path    => "/etc/puppet-dashboard/database.yml"
  } ->

  exec { 'db-migrate':
    command => 'rake RAILS_ENV=production db:migrate',
    cwd     => '/usr/share/puppet-dashboard',
    path    => '/usr/bin/:/usr/local/bin/',
    creates => "/var/lib/mysql/dashboard/nodes.frm"
  } ->

  ini_setting { 'enable puppet-dashboard-workers':
    ensure  => present,
    path    => '/etc/default/puppet-dashboard-workers',
    section => '',
    setting => 'START',
    value   => 'yes'
  } ->

  service { 'puppet-dashboard-workers':
    enable      => true,
    ensure      => 'running',
    hasrestart  => true
  }

  file { '/usr/share/puppet-dashboard/bin/cleanup_db.sh':
    ensure      => present,
    mode        => '0750',
    source      => "puppet:///modules/${module_name}/cleanup_db.sh",
    require     => Package['puppet-dashboard']
  } ->

  cron { 'cleanup_db.sh':
    command => '/usr/share/puppet-dashboard/bin/cleanup_db.sh > /dev/null',
    user    => root,
    hour    => 8,
    minute  => 30,
    weekday => 'Sunday',
  }
}
