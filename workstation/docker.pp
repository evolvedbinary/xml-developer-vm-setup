###
# Puppet Script for Docker on Ubuntu 22.04
###

apt::source { 'docker':
  location => 'https://download.docker.com/linux/ubuntu',
  release  => 'noble',
  repos    => 'stable',
  key      => {
    id     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
    name   => 'docker.asc',
    source => 'https://download.docker.com/linux/ubuntu/gpg',
  },
}

package { 'containerd.io':
  ensure  => installed,
  require => Apt::Source['docker'],
}

package { 'docker-ce':
  ensure  => installed,
  require => [
    Apt::Source['docker'],
    Package['containerd.io'],
  ],
}

package { 'docker-ce-cli':
  ensure  => installed,
  require => [
    Apt::Source['docker'],
    Package['docker-ce'],
  ],
}
~> exec { 'add_default_user_to_docker_group':
  command => "/usr/sbin/usermod --append --groups docker ${default_user}",
  require => User['default_user'],
}

package { 'docker-buildx-plugin':
  ensure  => installed,
  require => [
    Apt::Source['docker'],
    Package['docker-ce'],
  ],
}

package { 'docker-compose-plugin':
  ensure  => installed,
  require => [
    Apt::Source['docker'],
    Package['docker-ce'],
  ],
}

service { 'docker':
  ensure  => running,
  enable  => true,
  require => [
    Apt::Source['docker'],
    Package['docker-ce'],
    Package['docker-ce-cli'],
    Package['docker-buildx-plugin'],
    Package['docker-compose-plugin'],
  ],
}
