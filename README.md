# mysql_automysqlbackup

Install and configure the
[`automysqlbackup`](http://sourceforge.net/projects/automysqlbackup/)
script.

This is a EuPathDB BRC custom module.

    include '::mysql_automysqlbackup'

## Parameters affecting installation

`ensure` - `present` or `absent`

'cron_command' - The command you want the cron to run.  Defaults to /usr/local/sbin/automysqlbackup.sh

`cron_time` - array of hour and minute for cron, e.g.

    ['23', '5']

`backup_dir_owner` - existing user to run backup script and own backups

`backup_dir_group` - existing group to run backup script and own backups

## Parameters affecting `automysqlbackup.conf`

`mysql_dump_username` -  Username to access the MySQL server e.g. dbuser

`mysql_dump_password` - Password to access the MySQL server e.g. password

`mysql_dump_host` - Host name (or IP address) of MySQL server e.g localhost

`mysql_dump_host_friendly` - "Friendly" host name of MySQL server to be used in email log
 if unset or empty (default) will use `mysql_dump_host` instead

`backup_dir` - Backup directory location e.g /backups

`multicore` - This is practically a moot point, since there is a fallback to the compression
 functions without multicore support in the case that the multicore versions aren't
 present in the system. Of course, if you have the latter installed, but don't want
 to use them, just choose no here.
 pigz -> gzip
 pbzip2 -> bzip2

`multicore_threads` - Number of threads (= occupied cores) you want to use. You should - for the sake
 of the stability of your system - not choose more than (#number of cores - 1).
 Especially if the script is run in background by cron and the rest of your system
 has already heavy load, setting this too high, might crash your system. Assuming
 all systems have at least some sort of HyperThreading, the default is 2 threads.
 If you wish to let pigz and pbzip2 autodetect or use their standards, set it to
 'auto'.

`db_names` - List of databases for Daily/Weekly Backup e.g. ( 'DB1' 'DB2' 'DB3' ... )
 set to (), i.e. empty, if you want to backup all databases


`db_month_names` - List of databases for Monthly Backups.
 set to (), i.e. empty, if you want to backup all databases

`db_exclude` - List of DBNAMES to EXLUCDE if DBNAMES is empty, i.e. ().

`table_exclude` - List of tables to exclude, in the form db_name.table_name
 You may use wildcards for the table names, i.e. 'mydb.a*' selects all tables starting with an 'a'.
 However we only offer the wildcard '*', matching everything that could appear, which translates to the
 '%' wildcard in mysql.


`do_monthly` - Which day do you want monthly backups? (01 to 31)
 If the chosen day is greater than the last day of the month, it will be done
 on the last day of the month.
 Set to 0 to disable monthly backups.

`do_weekly` - Which day do you want weekly backups? (1 to 7 where 1 is Monday)
 Set to 0 to disable weekly backups.

`rotation_daily` - Set rotation of daily backups. VALUE*24hours
 If you want to keep only today's backups, you could choose 1, i.e. everything older than 24hours will be removed.

`rotation_weekly` - Set rotation for weekly backups. VALUE*24hours

`rotation_monthly` - Set rotation for monthly backups. VALUE*24hours

`mysql_dump_port` - Set the port for the mysql connection

`mysql_dump_commcomp` - Compress communications between backup server and MySQL server?

`mysql_dump_usessl` - Use ssl encryption with mysqldump?

`mysql_dump_socket` - For connections to localhost. Sometimes the Unix socket file must be specified.

`mysql_dump_max_allowed_packet` - The maximum size of the buffer for client/server communication. e.g. 16MB (maximum is 1GB)

`mysql_dump_single_transaction` - This option sends a START TRANSACTION SQL statement to the server before dumping data. It is useful only with
 transactional tables such as InnoDB, because then it dumps the consistent state of the database at the time
 when BEGIN was issued without blocking any applications. When using this option, you should keep in mind that only InnoDB tables are dumped in a consistent state. For
 example, any MyISAM or MEMORY tables dumped while using this option may still change state. While a --single-transaction dump is in process, to ensure a valid dump file (correct table contents and
 binary log coordinates), no other connection should use the following statements: ALTER TABLE, CREATE TABLE,
 DROP TABLE, RENAME TABLE, TRUNCATE TABLE. A consistent read is not isolated from those statements, so use of
 them on a table to be dumped can cause the SELECT that is performed by mysqldump to retrieve the table
 contents to obtain incorrect contents or fail.


`mysql_dump_master_data` - Use this option to dump a master replication server to produce a dump file that can be used to set up another
 server as a slave of the master. It causes the dump output to include a CHANGE MASTER TO statement that indicates
 the binary log coordinates (file name and position) of the dumped server. These are the master server coordinates
 from which the slave should start replicating after you load the dump file into the slave. If the option value is 2, the CHANGE MASTER TO statement is written as an SQL comment, and thus is informative only;
 it has no effect when the dump file is reloaded. If the option value is 1, the statement is not written as a comment
 and takes effect when the dump file is reloaded. If no option value is specified, the default value is 1. This option requires the RELOAD privilege and the binary log must be enabled. 
 The --master-data option automatically turns off --lock-tables. It also turns on --lock-all-tables, unless
 --single-transaction also is specified, in which case, a global read lock is acquired only for a short time at the
 beginning of the dump (see the description for --single-transaction). In all cases, any action on logs happens at
 the exact moment of the dump. Possible values are 1 and 2, which correspond with the values from mysqldump
 VARIABLE=, i.e. no value, turns it off (default)

`mysql_dump_full_schema` - Included stored routines (procedures and functions) for the dumped databases in the output. Use of this option
 requires the SELECT privilege for the mysql.proc table. The output generated by using --routines contains
 CREATE PROCEDURE and CREATE FUNCTION statements to re-create the routines. However, these statements do not
 include attributes such as the routine creation and modification timestamps. This means that when the routines
 are reloaded, they will be created with the timestamps equal to the reload time. If you require routines to be re-created with their original timestamp attributes, do not use --routines. Instead,
 dump and reload the contents of the mysql.proc table directly, using a MySQL account that has appropriate privileges
 for the mysql database. This option was added in MySQL 5.0.13. Before that, stored routines are not dumped. Routine DEFINER values are not
 dumped until MySQL 5.0.20. This means that before 5.0.20, when routines are reloaded, they will be created with the
 definer set to the reloading user. If you require routines to be re-created with their original definer, dump and
 load the contents of the mysql.proc table directly as described earlier.

`mysql_dump_dbstatus` - Backup status of table(s) in textfile. This is very helpful when restoring backups, since it gives an idea, what changed
 in the meantime.

`mysql_dump_create_database` - Include CREATE DATABASE in backup?

`mysql_dump_use_separate_dirs` - Separate backup directory and file for each DB? (yes or no)

`mysql_dump_compression` - Choose Compression type. (gzip or bzip2)

`mysql_dump_latest` - Store an additional copy of the latest backup to a standard
 location so it can be downloaded by third party scripts.

`mysql_dump_latest_clean_filenames` - Remove all date and time information from the filenames in the latest folder.
 Runs, if activated, once after the backups are completed. Practically it just finds all files in the latest folder
 and removes the date and time information from the filenames (if present).

`mysql_dump_differential` -  Create differential backups. Master backups are created weekly at #$`do_weekly weekday. Between master backups,
 diff is used to create differential backups relative to the latest master backup. In the Manifest file, you find the
 following structure

     $filename 	md5sum	$md5sum	diff_id	$diff_id	rel_id	$rel_id

 where each field is separated by the tabular character '\t'. The entries with $ at the beginning mean the actual values,
 while the others are just for readability. The `diff_id` is the id of the differential or master backup which is also in
 the filename after the last _ and before the suffixes begin, i.e. .diff, .sql and extensions. It is used to relate
 differential backups to master backups. The master backups have 0 as `$rel_id` and are thereby identifiable. Differential
 backups have the id of the corresponding master backup as `$rel_id`. To ensure that master backups are kept long enough, the value of $CONFIG_rotation_daily is set to a minimum of 21 days.


`mailcontent` - What would you like to be mailed to you?
 - log   : send only log file
 - files : send log file and sql files as attachments (see docs)
 - stdout : will simply output the log to the screen if run manually.
 - quiet : Only send logs if an error occurs to the MAILADDR.

`mail_maxattsize` - Set the maximum allowed email size in k. (4000 = approx 5MB email [see docs])

`mail_splitandtar` - Allow packing of files with tar and splitting it in pieces of `mail_maxattsize.

`mail_use_uuencoded_attachments` - Use uuencode instead of mutt. WARNING: Not all email clients work well with uuencoded attachments.

`mail_address` - Email Address to send mail to? (user@domain.com)

`encrypt` - Do you wish to encrypt your backups using openssl?

`encrypt_password` - Choose a password to encrypt the backups.

`backup_local_files` - Backup local files, i.e. maybe you would like to backup your my.cnf (mysql server configuration), etc.
 These files will be tar'ed, depending on your compression option `mysql_dump_compression` and
 depending on the option `encrypt`. Note: This could also have been accomplished with `prebackup` or `postbackup`.

`prebackup` - Command to run before backups (uncomment to use)

`postbackup` - Command run after backups (uncomment to use)

`dryrun` - dry-run, i.e. show what you are gonna do without actually doing it

     inactive: =0 or commented out
     active: uncommented AND =1
