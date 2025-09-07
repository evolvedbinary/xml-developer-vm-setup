###
# Puppet Script for IBM Db2 Community Edition on Ubuntu 24.04
###
$ibm_db2_major_version = '12'
$ibm_db2_minor_version = '1'
$ibm_db2_patch_version = '2'
$ibm_db2_version = "${ibm_db2_major_version}.${ibm_db2_minor_version}.${ibm_db2_patch_version}"
$ibm_db2_path = "/opt/ibm/db2/V${ibm_db2_major_version}.${ibm_db2_minor_version}"
$ibm_db2_setup_response_file = '/tmp/db2server.rsp'

exec { 'download-ibm-db2':
  command => "curl https://static.evolvedbinary.com/ibm/v${ibm_db2_version}_linuxx64_server_dec.tar.gz | tar zxv -C /tmp",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  creates => '/tmp/server_dec',
  unless  => "test -f ${ibm_db2_path}",
  require => [
    Package['file'],
    Package['curl'],
    Package['tar'],
  ],
}

$ibm_db2_response_file = @("IBM_DB2_RESPONSE_FILE_EOF":xml/L)
  *-----------------------------------------------------
  * Generated response file used by the DB2 Setup wizard
  * generation time: 08/09/2025, 14:14
  *-----------------------------------------------------
  *  Product Installation 
  LIC_AGREEMENT       = ACCEPT
  PROD       = DB2_SERVER_EDITION
  FILE       = ${ibm_db2_path}
  INSTALL_TYPE       = CUSTOM
  COMP       = IINR_APPLICATIONS_WRAPPER
  COMP       = SQL_PROCEDURES
  COMP       = ORACLE_DATA_SOURCE_SUPPORT
  COMP       = ODBC_DATA_SOURCE_SUPPORT
  COMP       = IINR_SCIENTIFIC_WRAPPER
  COMP       = INSTANCE_SETUP_SUPPORT
  COMP       = TERADATA_DATA_SOURCE_SUPPORT
  COMP       = FED_DATA_SOURCE_SUPPORT
  COMP       = CONNECT_SUPPORT
  COMP       = GUARDIUM_INST_MNGR_CLIENT
  COMP       = JDBC_DATA_SOURCE_SUPPORT
  COMP       = IINR_STRUCTURED_FILES_WRAPPER
  COMP       = BASE_DB2_ENGINE
  COMP       = REPL_CLIENT
  COMP       = JDK
  COMP       = DB2_SAMPLE_DATABASE
  COMP       = DB2_DATA_SOURCE_SUPPORT
  COMP       = SYBASE_DATA_SOURCE_SUPPORT
  COMP       = JAVA_SUPPORT
  COMP       = SQL_SERVER_DATA_SOURCE_SUPPORT
  COMP       = FIRST_STEPS
  COMP       = BASE_CLIENT
  COMP       = COMMUNICATION_SUPPORT_TCPIP
  * ----------------------------------------------
  *  Instance properties           
  * ----------------------------------------------
  INSTANCE       = inst1
  inst1.ENABLE_SHARED_GROUP=NO
  inst1.TYPE       = ese
  *  Instance-owning user
  inst1.NAME       = db2inst1
  inst1.GROUP_NAME       = db2iadm1
  inst1.HOME_DIRECTORY       = /home/db2inst1
  * inst1.PASSWORD       = db2
  inst1.PASSWORD       = 363101334436503442531642436142561853473658648143441333047367812461613255354820241804216936584116614540977540958402553635583245162265244754666254923037342362953338232858216478026733837123460624042264566818927700423574190033662140835160463441329473421466692523337570510168485256751667323370446326251213251800296033244694899419296357405283244426079361047175602967815667745934631354153336000361326404533368911461239426612981543574008515338969879152802651862165539051084281426491644419391364584593564512666311026079125531427386592968502167723169709337344150448944349326929958241236124617556530258302975714143054246941187295353239675661516168174763440755425559340960222042942871344536536345133516213296884665421767421732047148464574334764667743524292604143321314062305495453
  ENCRYPTED       = inst1.PASSWORD
  inst1.AUTOSTART       = YES
  inst1.SVCENAME       = db2c_db2inst1
  inst1.PORT_NUMBER       = 25000
  inst1.FCM_PORT_NUMBER       = 20000
  inst1.MAX_LOGICAL_NODES       = 6
  inst1.CONFIGURE_TEXT_SEARCH       = NO
  *  Fenced user
  inst1.FENCED_USERNAME       = db2fenc1
  inst1.FENCED_GROUP_NAME       = db2fadm1
  inst1.FENCED_HOME_DIRECTORY       = /home/db2fenc1
  * inst1.FENCED_PASSWORD       = db2
  inst1.FENCED_PASSWORD       = 612536021711088274911474162012587883671053521163247659255474300121338730859656395658937283332698612132042063954164520598753456221210506708296121733684022994683201641422432621331284224699432642389665962235458183521613410732076202511220820501727115590434188722524582419258945242217817114444622561263032361893642445360373169312731904327578893420184333643372694532323902634375477193533349155733530833835994133483351603693098347664167981204486672125537816352032354434527462257151856661272696095368286431238734516424662237554489447305067018932013538637662261329655317470992504833926275773357411815332853745673322536911494113494932195555046435630934121724222421781996882262548529511169363601958404170272792304430664363785125331939665124763555903828517234681506114306985245264
  ENCRYPTED       = inst1.FENCED_PASSWORD
  *-----------------------------------------------
  *  Installed Languages 
  *-----------------------------------------------
  LANG       = EN
  | IBM_DB2_RESPONSE_FILE_EOF

file { 'ibm-db2-setup-response-file':
  ensure  => file,
  path    => $ibm_db2_setup_response_file,
  owner   => 'root',
  group   => 'root',
  mode    => '0660',
  content => $ibm_db2_response_file,
}

package { 'libstdc++6':
  ensure => installed,
}

package { 'ksh':
  ensure => installed,
}

package { 'libncurses-dev':
  ensure => installed,
}

package { 'alien':
  ensure => installed,
}

package { 'libnuma1':
  ensure => installed,
}

package { 'binutils':
  ensure => installed,
}

package { 'libaio-dev':
  ensure => installed,
}

# NOTE(AR) IBM DB2 setup seems to require this file, but it is not present in the 'libaio-dev' package
file { '/usr/lib/x86_64-linux-gnu/libaio.so.1':
  ensure  => link,
  target  => '/usr/lib/x86_64-linux-gnu/libaio.so.1t64.0.2',
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => Package['libaio-dev'],
}

exec { 'install-ibm-db2':
  command     => "/tmp/server_dec/db2setup -r ${ibm_db2_setup_response_file}",
  environment => [
    'HOME=/root',
  ],
  user        => 'root',
  group       => 'root',
  provider    => shell,
  creates     => "${ibm_db2_path}/bin/db2",
  require     => [
    Exec['download-ibm-db2'],
    File['ibm-db2-setup-response-file'],
    Package['libstdc++6'],
    Package['ksh'],
    Package['libncurses-dev'],
    Package['alien'],
    Package['libnuma1'],
    Package['binutils'],
    Package['libaio-dev'],
    File['/usr/lib/x86_64-linux-gnu/libaio.so.1'],
  ],
}

service { 'db2fmcd':
  ensure  => running,
  require => Exec['install-ibm-db2'],
}

exec { 'install-sample-db':
  command     => '/home/db2inst1/sqllib/bin/db2sampl',
  cwd         => '/home/db2inst1',
  environment => [
    'DB2INSTANCE=db2inst1',
    'DB2LIB=/home/db2inst1/sqllib/lib',
    'DB2_HOME=/home/db2inst1/sqllib',
    'IBM_DB_DIR=/home/db2inst1/sqllib',
    'IBM_DB_HOME=/home/db2inst1/sqllib',
    'IBM_DB_INCLUDE=/home/db2inst1/sqllib/include',
  ],
  user        => 'db2inst1',
  group       => 'db2iadm1',
  creates     => '/home/db2inst1/db2inst1/NODE0000/SAMPLE',
  provider    => shell,
  require     => Service['db2fmcd'],
}

# DB2 JDBC driver - /opt/ibm/db2/V11.5/java/db2jcc4.jar
## JDBC connection string - jdbc:db2://localhost:25000/<database>

# Add DB2 Client Desktop link

xdesktop::shortcut { 'DB2 Client':
  application_path => 'su - db2inst1 -c db2',
  application_icon => "${ibm_db2_path}/desktop/icons/db2.xpm",
  terminal         => true,
  startup_notify   => false,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 214,
    y        => 321,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Exec['install-ibm-db2'],
  ],
}

# TODO(AR) - Add SQL files for data to the exercises folder
