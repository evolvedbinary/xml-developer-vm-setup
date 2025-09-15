###
# Puppet Script for an Elemental Developer Environment on Ubuntu 24.04
###

include ufw

$elemental_source_folder_owner = $default_user
$elemental_source_folder = "/home/${elemental_source_folder_owner}/code/elemental"

$app_mount  = '/opt'
$data_mount = '/data'

$sys_elemental_home = "${app_mount}/elemental"
$sys_elemental_data = "${data_mount}/elemental"
$sys_elemental_user = 'edb01'
$sys_elemental_group = 'edb01'

file { 'elemental_source_folder':
  ensure  => directory,
  path    => $elemental_source_folder,
  replace => false,
  owner   => $elemental_source_folder_owner,
  group   => $elemental_source_folder_owner,
  require => File['default_user_code_folder'],
}

vcsrepo { 'elemental_source':
  ensure             => latest,
  path               => $elemental_source_folder,
  provider           => git,
  source             => 'https://github.com/evolvedbinary/elemental.git',
  revision           => 'develop-7.x.x',
  keep_local_changes => false,  # TODO(AR) change this to 'true' once https://github.com/puppetlabs/puppetlabs-vcsrepo/pull/623 is merged and released
  owner              => $elemental_source_folder_owner,
  group              => $elemental_source_folder_owner,
  require            => [
    Package['git'],
    File['elemental_source_folder'],
  ],
}

group { 'sys_elemental_group':
  ensure => present,
  name   => $sys_elemental_group,
  system => true,
}

user { 'sys_elemental_user':
  ensure     => present,
  name       => $sys_elemental_user,
  gid        => $sys_elemental_group,
  comment    => 'Elemental Server Service Account',
  system     => true,
  managehome => false,
  home       => '/nonexistent',
  shell      => '/usr/sbin/nologin',
  require    => Group['sys_elemental_group'],
}

file { 'app_mount':
  ensure  => directory,
  path    => $app_mount,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}

file { 'sys_elemental_home':
  ensure  => directory,
  path    => $sys_elemental_home,
  replace => false,
  owner   => $sys_elemental_user,
  group   => $sys_elemental_group,
  mode    => '0775',
  require => [
    User['sys_elemental_user'],
    Group['sys_elemental_group'],
    File['app_mount'],
  ],
}

file { 'data_mount':
  ensure  => directory,
  path    => $data_mount,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}

file { 'sys_elemental_data':
  ensure  => directory,
  path    => $sys_elemental_data,
  replace => false,
  owner   => $sys_elemental_user,
  group   => $sys_elemental_group,
  mode    => '0770',
  require => [
    User['sys_elemental_user'],
    Group['sys_elemental_group'],
    File['data_mount'],
  ],
}

exec { 'compile-elemental':
  cwd         => $elemental_source_folder,
  command     => "${elemental_source_folder}/build.sh quick",
  environment => [
    'JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64',
    "HOME=/home/${default_user}",
  ],
  user        => $elemental_source_folder_owner,
  creates     => "${elemental_source_folder}/exist-distribution/target/elemental-${elemental_version}-dir",
  timeout     => 600,
  require     => [
    Package['temurin-21-jdk'],
    File['/opt/maven']
  ],
}
-> exec { 'deploy-elemental':
  command => "/usr/bin/cp -r ${elemental_source_folder}/exist-distribution/target/elemental-${elemental_version}-dir/* ${sys_elemental_home}/",
  creates => "${sys_elemental_home}/lib",
  require => File['sys_elemental_home'],
}
~> augeas { 'set-elemental-data-dir':
  incl    => "${sys_elemental_home}/etc/conf.xml",
  lens    => 'Xml.lns',
  changes => [
    "set exist/db-connection/#attribute/files \"${sys_elemental_data}\"",
    "set exist/db-connection/recovery/#attribute/journal-dir \"${sys_elemental_data}\"",
  ],
}
~> exec { 'set-elemental-owner':
  command => "/usr/bin/chown -R ${sys_elemental_user}:${sys_elemental_group} ${sys_elemental_home}",
  user    => 'root',
  require => [
    User['sys_elemental_user'],
    Group['sys_elemental_group'],
    File['sys_elemental_home'],
  ],
}
~> exec { 'set-elemental-db-admin-password':
  command     => "${sys_elemental_home}/bin/client.sh -s -l --user admin --xpath \"sm:passwd('admin', '${elemental_db_admin_password}')\"",
  environment => [
    'JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64',
  ],
  creates     => "${sys_elemental_data}/collections.dbx",
  user        => $sys_elemental_user,
  require     => [
    User['sys_elemental_user'],
    File['sys_elemental_home'],
    File['sys_elemental_data'],
  ],
}

file { '/etc/systemd/system/elemental.service':
  ensure  => file,
  replace => false,
  owner   => $sys_elemental_user,
  group   => $sys_elemental_group,
  require => [
    User['sys_elemental_user'],
    Group['sys_elemental_group'],
    File['sys_elemental_home'],
    File['sys_elemental_data'],
  ],
  content => "[Unit]
Description=Elemental Server
Documentation=https://www.elemental.xyz
After=syslog.target

[Service]
Type=simple
User=${sys_elemental_user}
Group=${sys_elemental_group}
Environment=\"JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64\"
ExecStart=${sys_elemental_home}/bin/startup.sh

[Install]
WantedBy=multi-user.target
",
}
~> exec { 'systemd-reload':
  command => 'systemctl daemon-reload',
  path    => '/usr/bin',
  user    => 'root',
}

service { 'elemental':
  ensure  => running,
  name    => 'elemental',
  enable  => true,

  require => [
    File['/etc/systemd/system/elemental.service'],
    Exec['systemd-reload'],
    Exec['set-elemental-db-admin-password'],
    Service['chronyd'],
  ],
}

ufw::allow { 'elemental':
  port    => '8080',
  require => Service['elemental'],
}
