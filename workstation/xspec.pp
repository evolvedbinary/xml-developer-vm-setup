###
# Puppet Script for XSpec 3 on Ubuntu 24.04
###

$xspec_version = '3.3.2'
$xspec_install_path = "/opt/xspec-${calabash_version}"
$xspec_group = 'xspec'

group { $xspec_group:
  ensure  => present,
  name    => $xspec_group,
  members => [
    $default_user,
  ],
  require => User['default_user'],
}
~> exec { 'add_default_user_to_xspec_group':
  command => "/usr/sbin/usermod --append --groups ${xspec_group} ${default_user}",
  require => User['default_user'],
}

file { $xspec_install_path:
  ensure  => directory,
  owner   => 'root',
  group   => $xspec_group,
  mode    => '2775',
  require => Group[$xspec_group],
}

file { '/opt/xspec':
  ensure  => link,
  target  => $xspec_install_path,
  replace => false,
  owner   => 'root',
  group   => $xspec_group,
  require => [
    File[$xspec_install_path],
    Group[$xspec_group],
  ],
}

vcsrepo { 'xspec_source':
  ensure             => latest,
  path               => $xspec_install_path,
  provider           => git,
  source             => 'https://github.com/xspec/xspec.git',
  revision           => "v${xspec_version}",
  keep_local_changes => false,  # TODO(AR) change this to 'true' once https://github.com/puppetlabs/puppetlabs-vcsrepo/pull/623 is merged and released
  owner              => 'root',
  group              => $xspec_group,
  require            => [
    Package['git'],
    File[$xspec_install_path],
    Group[$xspec_group]
  ],
}

file { "${xspec_install_path}/test":
  ensure  => directory,
  owner   => 'root',
  group   => $xspec_group,
  mode    => '2775',
  require => [
    Vcsrepo['xspec_source'],
    Group[$xspec_group],
  ],
}

file { "${xspec_install_path}/test/xspec":
  ensure  => directory,
  owner   => 'root',
  group   => $xspec_group,
  mode    => '2775',
  require => [
    File["${xspec_install_path}/test"],
    Group[$xspec_group],
  ],
}
