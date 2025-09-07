###
# Puppet Script for Eclipse IDE on Ubuntu 24.04
###

$eclipse_version = '2024-09'

file { "/opt/eclipse-${eclipse_version}":
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'install-eclipse':
  command => "curl https://mirror.ibcp.fr/pub/eclipse/technology/epp/downloads/release/${eclipse_version}/R/eclipse-java-${eclipse_version}-R-linux-gtk-x86_64.tar.gz | tar zxv -C /opt/eclipse-${eclipse_version} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/eclipse-${eclipse_version}/eclipse",
  require => [
    File["/opt/eclipse-${eclipse_version}"],
    Package['curl']
  ],
}

file { '/opt/eclipse':
  ensure  => link,
  target  => "/opt/eclipse-${eclipse_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File["/opt/eclipse-${eclipse_version}"],
}

xdesktop::shortcut { 'Eclipse':
  application_path => '/opt/eclipse/eclipse',
  application_icon => '/opt/eclipse/icon.xpm',
  startup_notify   => false,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 113,
    y        => 424,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    File['/opt/eclipse'],
  ],
}
