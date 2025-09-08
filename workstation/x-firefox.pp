###
# Puppet Script for Firefox on Ubuntu 24.04
###

package { 'firefox':
  ensure  => installed,
  require => Package['desktop'],
}

xdesktop::shortcut { 'Firefox':
  application_path => '/usr/bin/firefox',
  application_icon => '/usr/share/icons/hicolor/128x128/apps/firefox.png',
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 113,
    y        => 115,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Package['firefox'],
  ],
}
