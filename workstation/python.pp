###
# Puppet Script for Python 3 on Ubuntu
###

package { 'python3':
  ensure => installed,
}

package { 'python3-pip':
  ensure  => installed,
  require => Package['python3'],
}
