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
xdesktop::shortcut { 'Postgres Admin':
  shortcut_source => '/usr/share/applications/pgadmin4.desktop',
  user            => $default_user,
  position        => {
    provider => 'lxqt',
    x        => 214,
    y        => 424,
  },
  require         => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Package['pgadmin4-desktop'],
  ],
}
