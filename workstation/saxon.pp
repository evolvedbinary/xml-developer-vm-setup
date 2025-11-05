###
# Puppet Script for Saxon HE 12 on Ubuntu 24.04
###

$saxon_download_version = '12-9'
$saxon_jar_version = '12.9'
$saxon_install_path = "/opt/saxon-${saxon_jar_version}"

file { $saxon_install_path:
  ensure => directory,
}

file { '/opt/saxon':
  ensure  => link,
  target  => $saxon_install_path,
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File[$saxon_install_path],
}

exec { 'download-saxon-zip':
  command => "/usr/bin/curl -L https://github.com/Saxonica/Saxon-HE/releases/download/SaxonHE${saxon_download_version}/SaxonHE${saxon_download_version}J.zip -o /tmp/SaxonHE${saxon_download_version}J.zip",
  creates => "${saxon_install_path}/saxon-he-${saxon_jar_version}.jar",
  require => [
    Package['curl'],
    File[$saxon_install_path]
  ],
}

exec { 'install-saxon':
  command => "/usr/bin/unzip /tmp/SaxonHE${saxon_download_version}J.zip -d /opt/saxon-${saxon_jar_version}",
  creates => "${saxon_install_path}/saxon-he-${saxon_jar_version}.jar",
  require => [
    Package['zip'],
    Exec['download-saxon-zip']
  ],
}

file_line { 'SAXON_HOME':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'SAXON_HOME=/opt/saxon',
  match   => '^SAXON_HOME\=',
  require => File['/opt/saxon'],
}
