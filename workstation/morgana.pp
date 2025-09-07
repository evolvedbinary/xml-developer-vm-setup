###
# Puppet Script for Morgana XProc III on Ubuntu 24.04
###

$morgana_ee_version = '1.7'
$morgana_install_path = "/opt/MorganaXProc-IIIee-${morgana_ee_version}"

file { $morgana_install_path:
  ensure => directory,
}

file { '/opt/morgana':
  ensure  => link,
  target  => $morgana_install_path,
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File[$morgana_install_path],
}

exec { 'download-morgana-zip':
  command => "/usr/bin/curl -L https://static.evolvedbinary.com/morgana/MorganaXProc-IIIee-${morgana_ee_version}.zip -o /tmp/MorganaXProc-IIIee-${morgana_ee_version}.zip",
  creates => "${morgana_install_path}/MorganaXProc-IIIee.jar",
  require => [
    # Package['curl'],
    File[$morgana_install_path]
  ],
}

exec { 'install-morgana':
  command => "/usr/bin/unzip /tmp/MorganaXProc-IIIee-${morgana_ee_version}.zip -d /opt -x \"__MACOSX/*\"",
  creates => "${morgana_install_path}/MorganaXProc-IIIee.jar",
  require => [
    # Package['zip'],
    Exec['download-morgana-zip']
  ],
}

file { "${morgana_install_path}/MorganaEE.sh":
  ensure  => file,
  mode    => '0775',
  require => Exec['install-morgana'],
}
