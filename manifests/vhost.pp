class puppet-dashboard::vhost {

  $dashboard_port = 3000
  $docroot = '/usr/share/puppet-dashboard/public'
  $rails_base_uri = '/'
  $server_name = 'puppet'

  file { 'dashboard-vhost':
    mode    => '0644',
    owner   => 'www-data',
    group   => 'www-data',
    content => template("${module_name}/puppetdashboard.erb"),
    path    => "/etc/apache2/sites-available/puppetdashboard",
    require => Package[ 'puppet-dashboard' ]
  }
}