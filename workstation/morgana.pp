###
# Puppet Script for Morgana XProc III on Ubuntu
###

$morgana_ee_version = '1.8.9'
$morgana_install_path = "/opt/MorganaXProc-IIIee-${morgana_ee_version}"

$morgana_license_txt = @(MORGANA_LICENSE_TXT_EOF:xml/L)
Product:MorganaXProc-III
Edition:EE
Licensee:Evolved Binary Ltd, Watford, UK
eMail:adam@evolvedbinary.com
Issued:2026-09-14
UpgradeDays:30
Licence-No:63/24
Valid only on one computer
1F7850D64B30670C92062881AF9D113085918A0C044E8F7398FD4B4060142B29FCBCF977D606AC56A3AC17A769F00DB04E220DEBA8734A2BA6AF5C43EFFD3C06
  | MORGANA_LICENSE_TXT_EOF

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
    Package['curl'],
    File[$morgana_install_path]
  ],
}

exec { 'install-morgana':
  command => "/usr/bin/unzip /tmp/MorganaXProc-IIIee-${morgana_ee_version}.zip -d ${morgana_install_path} -x \"__MACOSX/*\"",
  creates => "${morgana_install_path}/MorganaXProc-IIIee.jar",
  require => [
    Package['zip'],
    Exec['download-morgana-zip']
  ],
}

file { "${morgana_install_path}/MorganaEE.sh":
  ensure  => file,
  mode    => '0775',
  require => Exec['install-morgana'],
}

file { "${morgana_install_path}/morgana-license.txt":
  ensure  => file,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0444',
  content => $morgana_license_txt,
  require => File[$morgana_install_path],
}
