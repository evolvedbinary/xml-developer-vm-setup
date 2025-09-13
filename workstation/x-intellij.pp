###
# Puppet Script for IntelliJ IDEA CE on Ubuntu 24.04
###

$intellij_idea_version_short = '2025.2'
$intellij_idea_version = "${intellij_idea_version_short}.1"

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

file { "/home/${default_user}/.local/share/JetBrains":
  ensure  => directory,
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0775',
  require => File['default_user_local_share_folder'],
}

file { "/home/${default_user}/.local/share/JetBrains/IdeaIC${intellij_idea_version_short}":
  ensure  => directory,
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0775',
  require => File["/home/${default_user}/.local/share/JetBrains"],
}

# Install 3rd-party LNKD.tech Editor Plugin for RDF
exec { 'download-lnkd-tech-plugin-zip':
  command => '/usr/bin/curl -L "https://downloads.marketplace.jetbrains.com/files/12802/744673/LNKD.tech_Editor-2025.0.1.zip?updateId=744673&pluginId=12802&family=INTELLIJ" -o /tmp/LNKD.tech_Editor-2025.0.1.zip',
  creates => "/home/${default_user}/.local/share/JetBrains/IdeaIC${intellij_idea_version_short}/LNKD.tech Editor",
  require => [
    Package['curl'],
    File["/home/${default_user}/.local/share/JetBrains/IdeaIC${intellij_idea_version_short}"]
  ],
}

exec { 'install-lnkd-tech-plugin':
  command => "/usr/bin/unzip /tmp/LNKD.tech_Editor-2025.0.1.zip -d /home/${default_user}/.local/share/JetBrains/IdeaIC${intellij_idea_version_short}",
  creates => "/home/${default_user}/.local/share/JetBrains/IdeaIC${intellij_idea_version_short}/LNKD.tech Editor",
  require => [
    Package['zip'],
    Exec['download-lnkd-tech-plugin-zip']
  ],
}
