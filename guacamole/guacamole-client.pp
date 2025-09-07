###
# Puppet Script to build and install Guacamole Client on Ubuntu 24.04
###

$guacamole_client_source_folder = "/home/${default_user}/code/guacamole-client"

file { 'guacamole-client-source-folder':
  ensure  => directory,
  path    => $guacamole_client_source_folder,
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  require => File['default_user_code_folder'],
}

vcsrepo { 'guacamole-client-source':
  ensure             => latest,
  path               => $guacamole_client_source_folder,
  provider           => git,
  source             => 'https://github.com/apache/guacamole-client.git',
  revision           => 'main',
  keep_local_changes => false,  # TODO(AR) change this to 'true' once https://github.com/puppetlabs/puppetlabs-vcsrepo/pull/623 is merged and released
  owner              => $default_user,
  group              => $default_user,
  require            => [
    Package['git'],
    File['guacamole-client-source-folder'],
  ],
}

exec { 'guacamole-client-compile':
  cwd      => $guacamole_client_source_folder,
  command  => '/opt/maven/bin/mvn package',
  provider => shell,
  user     => $default_user,
  creates  => "${guacamole_client_source_folder}/target",
  require  => [
    Vcsrepo['guacamole-client-source'],
    Package['openjdk-17-jdk-headless'],
    File['/opt/maven'],
  ],
}

file { '/etc/guacamole':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}

file { '/etc/guacamole/lib':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
  require => File['/etc/guacamole'],
}

file { '/etc/guacamole/extensions':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
  require => File['/etc/guacamole'],
}

$guacamole_properties = @("GUACAMOLE_PROPERTIES_EOF"/L)
  allowed-languages: en
  guacd-hostname: localhost
  guacd-port: 4822
  | GUACAMOLE_PROPERTIES_EOF

file { '/etc/guacamole/guacamole.properties':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0744',
  content => $guacamole_properties,
  require => File['/etc/guacamole'],
}

$user_mapping = @("USER_MAPPING_EOF":xml/L)
  <user-mapping>
      <authorize username="xmldev-01" password="xmldev">
          <connection name="xmldev-01">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-01.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmldev-02" password="xmldev">
          <connection name="xmldev-02">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-02.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmldev-03" password="xmldev">
          <connection name="xmldev-03">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-03.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmldev-04" password="xmldev">
          <connection name="xmldev-04">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-04.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmldev-05" password="xmldev">
          <connection name="xmldev-05">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-05.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmldev-06" password="xmldev">
          <connection name="xmldev-06">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-06.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
        </authorize>
        <authorize username="xmldev-07" password="xmldev">
          <connection name="xmldev-07">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-07.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
        </authorize>
        <authorize username="xmldev-08" password="xmldev">
          <connection name="xmldev-08">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-08.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
        </authorize>
        <authorize username="xmldev-09" password="xmldev">
          <connection name="xmldev-09">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-09.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
        </authorize>
        <authorize username="xmldev-10" password="xmldev">
          <connection name="xmldev-10">
              <protocol>rdp</protocol>
              <param name="hostname">xmldev-10.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmldev_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
  </user-mapping>
  | USER_MAPPING_EOF

file { '/etc/guacamole/user-mapping.xml':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0744',
  content => $user_mapping,
  require => File['/etc/guacamole'],
}

file { 'guacamole-war':
  ensure  => file,
  path    => '/opt/tomcat/webapps/guacamole.war',
  source  => "${guacamole_client_source_folder}/guacamole/target/guacamole-1.6.0.war",
  require => [
    File['/etc/guacamole/guacamole.properties'],
    File['/etc/guacamole/user-mapping.xml'],
    File['/etc/guacamole/lib'],
    File['/etc/guacamole/extensions'],
    Exec['guacamole-client-compile'],
    Service['tomcat'],
  ],
}
