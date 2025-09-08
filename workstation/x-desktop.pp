###
# Puppet Script for a Desktop Developer Environment using LXQT on Ubuntu 22.04
###

$desktop_background_image_url = 'https://static.evolvedbinary.com/eb-desktop-background.png'
$desktop_background_image = "/home/${default_user}/Pictures/eb-desktop-background.png"
$desktop_background_color = '#ffffff'

file { 'disable-screensaver':
  ensure  => file,
  path    => "/home/${default_user}/.xscreensaver",
  replace => false,
  mode    => '0664',
  content => 'mode:    off',
}

file_line { 'disable-screensaver':
  ensure  => present,
  path    => "/home/${default_user}/.xscreensaver",
  line    => 'mode:    off',
  match   => '^mode:',
  require => File['disable-screensaver'],
}

package { 'desktop':
  ensure  => installed,
  name    => 'lubuntu-desktop',
  require => File_line['disable-screensaver'],
}

ini_setting { 'lxqt-session-userfile':
  ensure  => present,
  path    => "/home/${default_user}/.config/lxqt/session.conf",
  section => 'General',
  setting => '__userfile__',
  value   => 'true',
  require => Package['desktop'],
}

ini_setting { 'lxqt-session-window-manager':
  ensure  => present,
  path    => "/home/${default_user}/.config/lxqt/session.conf",
  section => 'General',
  setting => 'window_manager',
  value   => 'xfwm4',
  require => Package['desktop'],
}

# Workaround for https://bugs.launchpad.net/ubuntu/+source/lubuntu-default-settings/+bug/1708200
file { 'xterm':
  ensure  => link,
  path    => '/usr/bin/xterm',
  target  => '/usr/bin/qterminal',
  require => Package['desktop'],
}

file { 'default_user_desktop_folder':
  ensure  => directory,
  path    => "/home/${default_user}/Desktop",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0775',
  require => [
    Package['desktop'],
    File['default_user_home'],
  ],
}

file { "/home/${default_user}/Pictures":
  ensure => directory,
  owner  => $default_user,
  group  => $default_user,
  mode   => '0755',
}

exec { 'download-desktop-background':
  command => "curl ${desktop_background_image_url} -o ${desktop_background_image}",
  path    => '/usr/bin',
  user    => $default_user,
  creates => $desktop_background_image,
  require => [
    File["/home/${default_user}/Pictures"],
    File['default_user_desktop_folder'],
  ],
}

file { "/home/${default_user}/.config/pcmanfm-qt":
  ensure => directory,
  owner  => $default_user,
  group  => $default_user,
  mode   => '0775',
}

file { "/home/${default_user}/.config/pcmanfm-qt/lxqt":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0775',
  require => File["/home/${default_user}/.config/pcmanfm-qt"],
}

file { 'settings.conf':
  ensure  => file,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0664',
  require => File["/home/${default_user}/.config/pcmanfm-qt/lxqt"],
}

ini_setting { 'desktop_background_image':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'Wallpaper',
  value   => $desktop_background_image,
  require => [
    Package['desktop'],
    File['settings.conf'],
    Exec['download-desktop-background'],
  ],
}

ini_setting { 'desktop_background_mode':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'WallpaperMode',
  value   => 'fit',
  require => [
    Package['desktop'],
    File['settings.conf'],
    Exec['download-desktop-background'],
  ],
}

ini_setting { 'desktop_background_color':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'BgColor',
  value   => $desktop_background_color,
  require => [
    Package['desktop'],
    File['settings.conf'],
    Exec['download-desktop-background'],
  ],
}

file { 'desktop-items-0':
  ensure  => file,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => File["/home/${default_user}/.config/pcmanfm-qt/lxqt"],
}

xdesktop::shortcut { 'Computer':
  application_path => 'pcmanfm-qt computer:///',
  application_icon => 'computer',
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 12,
    y        => 12,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
  ],
}

xdesktop::shortcut { 'Home':
  application_path => "pcmanfm-qt /home/${default_user}",
  application_icon => 'user-home',
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 12,
    y        => 115,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
  ],
}

xdesktop::shortcut { 'Network':
  application_path => 'pcmanfm-qt network:///',
  application_icon => 'folder-network',
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 12,
    y        => 218,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
  ],
}

xdesktop::shortcut { 'Trash':
  application_path => 'pcmanfm-qt trash:///',
  application_icon => 'user-trash',
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 12,
    y        => 321,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
  ],
}

file_line { 'simplify-qterminalname-1':
  ensure  => present,
  path    => '/usr/share/applications/qterminal.desktop',
  line    => 'Name=Terminal',
  match   => '^Name\=QTerminal',
  require => Package['desktop'],
}

file_line { 'simplify-qterminalname-2':
  ensure  => present,
  path    => '/usr/share/applications/qterminal.desktop',
  line    => 'Name[en_GB]=Terminal',
  match   => '^Name[en_GB]\=Qterminal',
  require => Package['desktop'],
}

xdesktop::shortcut { 'Terminal':
  shortcut_source => '/usr/share/applications/qterminal.desktop',
  startup_notify  => true,
  user            => $default_user,
  position        => {
    provider => 'lxqt',
    x        => 12,
    y        => 630,
  },
  require         => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    File_line['simplify-qterminalname-1'],
    File_line['simplify-qterminalname-2'],
  ],
}

file_line { 'simplify-pcmanfm-qt-name':
  ensure  => present,
  path    => '/usr/share/applications/pcmanfm-qt.desktop',
  line    => 'Name=File Manager',
  match   => '^Name\=',
  require => Package['desktop'],
}

xdesktop::shortcut { 'File Manager':
  shortcut_source => '/usr/share/applications/pcmanfm-qt.desktop',
  startup_notify  => true,
  user            => $default_user,
  position        => {
    provider => 'lxqt',
    x        => 12,
    y        => 424,
  },
  require         => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    File_line['simplify-pcmanfm-qt-name'],
  ],
}

file_line { 'simplify-lxqt-archiver-name':
  ensure  => present,
  path    => '/usr/share/applications/lxqt-archiver.desktop',
  line    => 'Name=File Archiver',
  match   => '^Name\=',
  require => Package['desktop'],
}

xdesktop::shortcut { 'File Archiver':
  shortcut_source => '/usr/share/applications/lxqt-archiver.desktop',
  startup_notify  => true,
  user            => $default_user,
  position        => {
    provider => 'lxqt',
    x        => 12,
    y        => 527,
  },
  require         => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    File_line['simplify-lxqt-archiver-name'],
  ],
}
