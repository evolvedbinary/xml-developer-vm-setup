###
# Puppet Script for Google Chrome on Ubuntu 22.04
###

exec { 'download-google-chrome-deb':
  command => '/usr/bin/wget -P /tmp https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb',
  unless  => '/usr/bin/dpkg -s google-chrome-stable',
  user    => 'root',
  require => Package['wget'],
}

exec { 'install-google-chrome-deb':
  command => '/usr/bin/dpkg -i /tmp/google-chrome-stable_current_amd64.deb',
  unless  => '/usr/bin/dpkg -s google-chrome-stable',
  user    => 'root',
  require => [
    Package['desktop'],
    Exec['download-google-chrome-deb'],
  ],
}

file { 'google-chrome-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/google-chrome.desktop",
  source  => '/usr/share/applications/google-chrome.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Exec['install-google-chrome-deb'],
  ],
}

exec { 'gvfs-trust-google-chrome-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/google-chrome.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/google-chrome.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['google-chrome-desktop-shortcut'],
}
