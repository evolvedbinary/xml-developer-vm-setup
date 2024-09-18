###
# Puppet Script for Firefox on Ubuntu 22.04
###

package { 'firefox':
  ensure  => installed,
  require => Package['desktop'],
}

file { 'firefox-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/firefox.desktop",
  source  => '/usr/share/applications/firefox.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['firefox'],
  ],
}

exec { 'gvfs-trust-firefox-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/firefox.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/firefox.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['firefox-desktop-shortcut'],
}

ini_setting { 'firefox-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'firefox.desktop',
  setting => 'pos',
  value   => '@Point(113 115)',
  require => [
    File['desktop-items-0'],
    File['firefox-desktop-shortcut'],
  ],
}
