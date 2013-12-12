class puppet-dashboard ( $dashboard_password ) {
  include puppet-dashboard::vhost

  package { 'puppet-dashboard':
    ensure  => 'installed',
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
    replace => false,
    require => Package['puppet-dashboard'],
  }

  ini_setting { 'enable puppet-dashboard-workers':
    ensure  => present,
    path    => '/etc/default/puppet-dashboard-workers',
    section => '',
    setting => 'START',
    value   => 'yes',
    require => Package[ 'puppet-dashboard' ],
  }

  service { 'puppet-dashboard-workers':
    enable      => true,
    ensure      => 'running',
    hasrestart  => true,
    require     => Ini_setting['enable puppet-dashboard-workers'],
  }

  mysql::server::config { 'basic_config':
    settings => {
      'mysqld' => {
        'innodb_file_per_table'      => '1',
        'innodb_buffer_pool_size'    => '512M',
        'innodb_flush_method'        => 'O_DIRECT',
        'innodb_data_file_path'      => 'ibdata1:10M:autoextend:max:10G',
      }
    },
    require => Package['puppet-dashboard']
  }

  file { '/usr/share/puppet-dashboard/bin/cleanup_db.sh':
    ensure      => present,
    mode        => '0750',
    source      => "puppet:///modules/${module_name}/cleanup_db.sh",
    require     => Package['puppet-dashboard']
  }

  cron { 'cleanup_db.sh':
    command => '/usr/share/puppet-dashboard/bin/cleanup_db.sh > /dev/null',
    user    => root,
    hour    => 8,
    minute  => 30,
    weekday => 'Sunday',
  }
}
