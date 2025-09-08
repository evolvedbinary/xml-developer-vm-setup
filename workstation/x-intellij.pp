###
# Puppet Script for IntelliJ IDEA CE on Ubuntu 24.04
###

$intellij_idea_version = '2025.2.1'

file { "/opt/idea-IC-${intellij_idea_version}":
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'install-intellij-ce':
  command => "curl -L https://download.jetbrains.com/idea/ideaIC-${intellij_idea_version}.tar.gz | tar zxv -C /opt/idea-IC-${intellij_idea_version} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/idea-IC-${intellij_idea_version}/bin/idea.sh",
  require => [
    File["/opt/idea-IC-${intellij_idea_version}"],
    Package['curl']
  ],
}

file { '/opt/idea-IC':
  ensure  => link,
  target  => "/opt/idea-IC-${intellij_idea_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File["/opt/idea-IC-${intellij_idea_version}"],
}

xdesktop::shortcut { 'IntelliJ IDEA CE':
  application_path => '/opt/idea-IC/bin/idea',
  application_icon => '/opt/idea-IC/bin/idea.svg',
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 113,
    y        => 218,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    File['/opt/idea-IC'],
  ],
}
