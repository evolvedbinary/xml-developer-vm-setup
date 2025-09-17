###
# Puppet Script for installing the Course Exercises on Ubuntu 24.04
###

$exercises_url = 'https://static.evolvedbinary.com/xmlss25/Exercises.zip'
$exercises_install_path = "/home/${default_user}/Desktop/Exercises"

$vocabularies_url = 'https://static.evolvedbinary.com/xmlss/Vocabularies.zip'
$vocabularies_install_path = "/home/${default_user}/Desktop/Vocabularies"

file { $exercises_install_path:
  ensure  => directory,
  require => File['default_user_desktop_folder'],
  owner   => $default_user,
  group   => $default_user,
  mode    => '0770',
}

exec { 'download-exercises-zip':
  command => "/usr/bin/curl -L ${exercises_url} -o /tmp/Exercises.zip",
  creates => "${exercises_install_path}/Samples",
  require => [
    Package['curl'],
    File[$exercises_install_path]
  ],
}

exec { 'install-exercises':
  command => "/usr/bin/unzip -o /tmp/Exercises.zip -d /home/${default_user}/Desktop",
  creates => "${exercises_install_path}/Samples",
  user    => $default_user,
  require => [
    Package['zip'],
    Exec['download-exercises-zip'],
  ],
}

file { $vocabularies_install_path:
  ensure  => directory,
  require => File['default_user_desktop_folder'],
}

exec { 'download-vocabularies-zip':
  command => "/usr/bin/curl -L ${vocabularies_url} -o /tmp/Vocabularies.zip",
  creates => "${vocabularies_install_path}/adms.ttl",
  require => [
    Package['curl'],
    File[$vocabularies_install_path]
  ],
}

exec { 'install-vocabularies':
  command => "/usr/bin/unzip -o /tmp/Vocabularies.zip -d /home/${default_user}/Desktop",
  creates => "${vocabularies_install_path}/adms.ttl",
  require => [
    Package['zip'],
    Exec['download-vocabularies-zip'],
  ],
}
