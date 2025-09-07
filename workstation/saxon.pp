###
# Puppet Script for Saxon HE 12 on Ubuntu 24.04
###

$saxon_download_version = '12-5'
$saxon_jar_version = '12.5'

file { "/opt/saxon-${saxon_jar_version}":
  ensure => directory,
}

exec { 'download-saxon-zip':
  command => "/usr/bin/curl -L https://github.com/Saxonica/Saxon-HE/releases/download/SaxonHE${saxon_download_version}/SaxonHE${saxon_download_version}J.zip -o /tmp/SaxonHE${saxon_download_version}J.zip",
  creates => "/opt/saxon-${saxon_jar_version}/saxon-he-${saxon_jar_version}.jar",
  require => [
    # Package['curl'],
    File["/opt/saxon-${saxon_jar_version}"]
  ],
}

exec { 'install-saxon':
  command => "/usr/bin/unzip /tmp/SaxonHE${saxon_download_version}J.zip -d /opt/saxon-${saxon_jar_version}",
  creates => "/opt/saxon-${saxon_jar_version}/saxon-he-${saxon_jar_version}.jar",
  require => [
    # Package['zip'],
    Exec['download-saxon-zip']
  ],
}
