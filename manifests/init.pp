# See README.me for usage.
class mysql_automysqlbackup (
  $ensure                            = 'present',
  $cron_time                         = ['23', '5'],
  $cron_command                      = '/usr/local/sbin/automysqlbackup.sh',
  $backup_dir_owner                  = 'root',
  $backup_dir_group                  = 'root',
  # START /etc/automysqlbackup.conf parameters
  $mysql_dump_username               = undef,
  $mysql_dump_password               = undef,
  $mysql_dump_host                   = undef,
  $mysql_dump_host_friendly          = undef,
  $backup_dir                        = undef,
  $multicore                         = undef,
  $multicore_threads                 = undef,
  $db_names                          = undef,
  $db_month_names                    = undef,
  $db_exclude                        = undef,
  $table_exclude                     = undef,
  $do_monthly                        = undef,
  $do_weekly                         = undef,
  $rotation_daily                    = undef,
  $rotation_weekly                   = undef,
  $rotation_monthly                  = undef,
  $mysql_dump_port                   = undef,
  $mysql_dump_commcomp               = undef,
  $mysql_dump_usessl                 = undef,
  $mysql_dump_socket                 = undef,
  $mysql_dump_max_allowed_packet     = undef,
  $mysql_dump_single_transaction     = undef,
  $mysql_dump_master_data            = undef,
  $mysql_dump_full_schema            = undef,
  $mysql_dump_dbstatus               = undef,
  $mysql_dump_create_database        = undef,
  $mysql_dump_use_separate_dirs      = undef,
  $mysql_dump_compression            = undef,
  $mysql_dump_latest                 = undef,
  $mysql_dump_latest_clean_filenames = undef,
  $mysql_dump_differential           = undef,
  $mailcontent                       = undef,
  $mail_maxattsize                   = undef,
  $mail_splitandtar                  = undef,
  $mail_use_uuencoded_attachments    = undef,
  $mail_address                      = undef,
  $encrypt                           = undef,
  $encrypt_password                  = undef,
  $backup_local_files                = undef,
  $prebackup                         = undef,
  $postbackup                        = undef,
  $dryrun                            = undef,
  # END /etc/automysqlbackup.conf parameters
) {

  $privs = [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS', 'TRIGGER' ]

  if $mysql_dump_username != 'root' {
    mysql_user { "${mysql_dump_username}@localhost":
      ensure        => $ensure,
      password_hash => mysql_password($mysql_dump_password),
      require       => Class['mysql::server::root_password'],
    }
    mysql_grant { "${mysql_dump_username}@localhost/*.*":
      ensure     => $ensure,
      user       => "${mysql_dump_username}@localhost",
      table      => '*.*',
      privileges => $privs,
      require    => Mysql_user["${mysql_dump_username}@localhost"],
    }
  }

  cron { 'mysql-backup':
    ensure  => $ensure,
    command => $cron_command,
    user    => $backup_dir_owner,
    hour    => $cron_time[0],
    minute  => $cron_time[1],
    require => File['automysqlbackup.sh'],
  }

  file { 'automysqlbackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/automysqlbackup.sh',
    mode    => '0700',
    owner   => $backup_dir_owner,
    group   => $backup_dir_group,
    content => template('mysql_automysqlbackup/automysqlbackup.sh.erb'),
  }

  file { '/etc/automysqlbackup':
    ensure => 'directory',
    mode    => '0700',
    owner   => $backup_dir_owner,
    group   => $backup_dir_group,
  }

  file { '/etc/automysqlbackup/automysqlbackup.conf':
    ensure  => $ensure,
    mode    => '0700',
    owner   => $backup_dir_owner,
    group   => $backup_dir_group,
    content => template('mysql_automysqlbackup/automysqlbackup.conf.erb'),
    require => File['/etc/automysqlbackup'],
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backup_dir,
    mode   => '0700',
    owner  => $backup_dir_owner,
    group  => $backup_dir_group,
  }

}
