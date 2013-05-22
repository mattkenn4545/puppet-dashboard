class puppet-dashboard::vhost {

  $dashboard_port = 3000
  $docroot = ''
  $rails_base_uri = '/'

  file { 'dashboard-vhost':
    mode    => '0644',
    owner   => 'www-data',
    group   => 'www-data',
    content => template("${module_name}/puppetdashboard.erb"),
    path    => "/etc/apache/sites-available/puppetdashboard",
    require => Package[ 'puppet-dashboard' ]
  }
}