###
# Puppet Script for pgAdmin on Ubuntu 22.04
###

include apt

apt::source { 'pgadmin':
  location => 'https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/jammy',
  release  => 'pgadmin4',
  repos    => 'main',
  comment  => 'pgAdmin',
  key      => {
    id     => 'E8697E2EEF76C02D3A6332778881B2A8210976F2',
    source => 'https://www.pgadmin.org/static/packages_pgadmin_org.pub',
  },
}

package { 'pgadmin4-desktop':
  ensure  => installed,
  require => Apt::Source['pgadmin'],
}

# Add Desktop shortcut
file { 'pgadmin4-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/pgadmin4.desktop",
  source  => '/usr/share/applications/pgadmin4.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['pgadmin4-desktop'],
  ],
}

exec { 'gvfs-trust-pgadmin4-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/pgadmin4.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/pgadmin4.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['pgadmin4-desktop-shortcut'],
}

ini_setting { 'pgadmin4-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'pgadmin4.desktop',
  setting => 'pos',
  value   => '@Point(214 424)',
  require => [
    File['desktop-items-0'],
    File['pgadmin4-desktop-shortcut'],
  ],
}
