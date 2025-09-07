###
# Puppet Script for Python 3 on Ubuntu 24.04
###

package { 'python3':
  ensure => installed,
}

package { 'python3-pip':
  ensure  => installed,
  require => Package['python3'],
}
