# 10-auth.conf
# dovecot-sql.conf.ext
class dovecot::mysql (
  $dbname          = 'mails',
  $dbpassword      = 'admin',
  $dbusername      = 'pass',
  $dbhost          = 'localhost',
  $dbport          = 3306,
  $mailstorepath   = '/srv/vmail/',
  $sqlconftemplate = 'dovecot/dovecot-sql.conf.ext',

  $user_query      = undef,
  $password_query  = undef,
) {

  $driver = 'mysql'
  $userdb_sql = false

  file { "/etc/dovecot/dovecot-sql.conf.ext":
    ensure  => present,
    content => template($sqlconftemplate),
    mode    => '0600',
    owner   => root,
    group   => dovecot,
    require => Package['dovecot-mysql'],
    before  => Exec['dovecot'],
    notify  => Service['dovecot'],
  }
  file { "/etc/dovecot/conf.d/auth-sql.conf.ext":
    ensure  => present,
    content => template('dovecot/auth-sql.conf.ext'),
    mode    => '0600',
    owner   => root,
    group   => dovecot,
    require => Package['dovecot-mysql'],
    before  => Exec['dovecot'],
    notify  => Service['dovecot'],
  }

  package {'dovecot-mysql':
    ensure => installed,
    before => Exec['dovecot'],
    notify => Service['dovecot']
  }

  dovecot::config::dovecotcfmulti { 'sqlauth':
    config_file => 'conf.d/10-auth.conf',
    changes     => [
      "set include 'auth-sql.conf.ext'",
      "rm  include[ . = 'auth-system.conf.ext']",
    ],
    require     => File["/etc/dovecot/dovecot-sql.conf.ext"]
  }
}
