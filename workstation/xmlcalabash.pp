###
# Puppet Script for XML Calabash 3 on Ubuntu 24.04
###

$calabash_version = '3.0.16'
$calabash_install_path = "/opt/xmlcalabash-${calabash_version}"

file { $calabash_install_path:
  ensure => directory,
}

file { '/opt/xmlcalabash':
  ensure  => link,
  target  => $calabash_install_path,
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File[$calabash_install_path],
}

exec { 'download-calabash-zip':
  command => "/usr/bin/curl -L https://codeberg.org/xmlcalabash/xmlcalabash3/releases/download/${calabash_version}/xmlcalabash-${calabash_version}.zip -o /tmp/xmlcalabash-${calabash_version}.zip",
  creates => "${calabash_install_path}/xmlcalabash-app-${calabash_version}.jar",
  require => [
    # Package['curl'],
    File[$calabash_install_path]
  ],
}

exec { 'install-calabash':
  command => "/usr/bin/unzip /tmp/xmlcalabash-${calabash_version}.zip -d /opt",
  creates => "${calabash_install_path}/xmlcalabash-app-${calabash_version}.jar",
  require => [
    # Package['zip'],
    Exec['download-calabash-zip']
  ],
}
