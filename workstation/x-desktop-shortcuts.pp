###
# Puppet Script for extra Desktop Shortcuts on Ubuntu 22.04
###

file { 'dot-local':
  ensure  => directory,
  path    => "/home/${default_user}/.local",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => Package['desktop'],
}

file { 'dot-local-share':
  ensure  => directory,
  path    => "/home/${default_user}/.local/share",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => [
    Package['desktop'],
    File['dot-local'],
  ],
}

file { 'local-icons':
  ensure  => directory,
  path    => "/home/${default_user}/.local/share/icons",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0755',
  require => [
    Package['desktop'],
    File['dot-local-share'],
  ],
}

exec { 'download-existdb-x-logo':
  command => "wget -O /home/${default_user}/.local/share/icons/existdb-x.png https://raw.githubusercontent.com/eXist-db/exist/develop/exist-core/src/main/resources/org/exist/client/icons/x.png",
  path    => '/usr/bin',
  creates => "/home/${default_user}/.local/share/icons/existdb-x.png",
  user    => $default_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

xdesktop::shortcut { 'eXist-db Dashboard':
  application_path => '/usr/bin/google-chrome-stable http://localhost:8080',
  application_icon => "/home/${default_user}/.local/share/icons/existdb-x.png",
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 214,
    y        => 115,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Exec['download-existdb-x-logo'],
    Service['existdb'],
  ],
}

exec { 'download-eb-favicon-logo':
  command => "wget -O /home/${default_user}/.local/share/icons/eb-favicon-logo.svg https://evolvedbinary.com/images/icons/shape-icon.svg",
  path    => '/usr/bin',
  creates => "/home/${default_user}/.local/share/icons/eb-favicon-logo.svg",
  user    => $default_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

xdesktop::shortcut { 'The Complete XML Developer - Slides':
  application_path => '/usr/bin/google-chrome-stable https://static.evolvedbinary.com/cxd/',
  application_icon => "/home/${default_user}/.local/share/icons/eb-favicon-logo.svg",
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 214,
    y        => 12,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Exec['download-eb-favicon-logo'],
  ],
}
