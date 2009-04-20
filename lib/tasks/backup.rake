## example crontab entry:
##
## 0 3 * * * cd /var/www/suoc/current && nice rake backup RAILS_ENV=production >> /var/www/suoc/current/log/production_backup_system.log
##
## config file - goes in config/backup.yml
#
# # Archive Directory in which to place archive files
# archivedir: db/archives
# # Backup staging directory, in which to place the SQL Dump file
# backupdir: db/backup
# # SQL Dump file. File to which to dump the database. If relative path
# # it's relative to the Backup staging directory
# sqldumpfile: db.sql
# #
# # Directories to include in the archive.
# dirs:
#   - public/photos
#   - public/updloaded_files
#
# Each environment can override. For dirs, override absolute.
# production:
#   sqldumpfile: production.sql
# development:
#   sqldumpfile: development.sql
#   dirs:
#    - lib
#    - public/photos
#    - public/uploaded_files
# ## rake file lib/tasks/backup.rake

desc "Backup according to config/backup.yml"
task :backup => ["backup:dump", "backup:archive"]

namespace :backup do
    RAILS_APPDIR = RAILS_ROOT.sub("/config/..","")

    BACKUP_CONFIG = File.join("config", "backup.yml")

    # Constants
    YAML_ARCHIVEDIR_KEY  = "archivedir"
    YAML_BACKUPDIR_KEY   = "backupdir"
    YAML_SQLDUMPFILE_KEY = "sqldumpfile"
    YAML_DIRS_KEY        = "dirs"

    DEFAULT_ARCHIVEDIR     = File.join("db","archives")
    DEFAULT_BACKUPDIR      = File.join("db","backup")
    DEFAULT_SQL_BACKUPFILE = "db.sql"

    task :sqlite3 => [ "dumpsqlite3", "archive" ]

    def retrive_backup_config
      config = YAML::load(File.open(BACKUP_CONFIG))
      backupdir = config[RAILS_ENV][YAML_BACKUPDIR_KEY] ||
                  config[YAML_BACKUPDIR_KEY] || DEFAULT_BACKUPDIR
      archivedir = config[RAILS_ENV][YAML_ARCHIVEDIR_KEY] ||
                   config[YAML_ARCHIVEDIR_KEY] || DEFAULT_ARCHIVEDIR
      sqldumpfile = config[RAILS_ENV][YAML_SQLDUMPFILE_KEY] ||
                    config[YAML_SQLDUMPFILE_KEY] || DEFAULT_SQLDUMPFILE
      dirs        = config[RAILS_ENV][YAML_DIRS_KEY] ||
                    config[YAML_DIRS_KEY]
      [archivedir, backupdir, sqldumpfile, dirs]
   end
#
#    desc "Push backup to remote server"
#    task :push  => [:environment] do
#       FileUtils.chdir(RAILS_APPDIR)
#       backup_config = YAML::load( File.open( 'config/backup.yml' ) )[RAILS_ENV]
#       for server in backup_config["servers"]
#        puts "Backing up #{RAILS_ENV} directorys #{backup_config['dirs'].join(', ')} to #{server['name']}"
#        puts "Time is " + Time.now.rfc2822 + "\n\n"
#          for dir in backup_config["dirs"]
#           local_dir = RAILS_APPDIR + "/" + dir + "/"
#           remote_dir = server['dir'] + "/" + dir.split("/").last + "/"
#           puts "Syncing #{local_dir} to #{server['host']}#{remote_dir}"
#           sh "/usr/bin/rsync -avz -e 'ssh -p#{server['port']} ' #{local_dir} #{server['user']}@#{server['host']}:#{remote_dir}"
#          end
#        puts "Completed backup to #{server['name']}\n\n"
#       end
#    end

    desc "Dump Environment's Database to the backup directory"
    task :dump do
      archivedir, backupdir, sqldumpfile, dirs = retrive_backup_config

      unless File.fnmatch(File::SEPARATOR+"*", sqldumpfile)
        sqldumpfile = File.join(backupdir, sqldumpfile)
      end

      msg "Chdir to #{RAILS_APPDIR}"
      FileUtils.chdir(RAILS_APPDIR)
      FileUtils.mkdir_p(backupdir)
      msg "Retriving Database Configuration."
      adapter, database, user, password = retrieve_db_info

      msg "Dumping database."
      if adapter == "mysql"
        msg "Using MySql."
        cmd = "mysqldump --opt --skip-add-locks --quote-names --max-allowed-packet=600M -u #{user} "
        cmd += "-p'#{password}'" unless password.nil?
        cmd += " #{database} > #{sqldumpfile}"
      elsif adapter == "postgresql"
        msg "Using Postgres -- this is untested."
        cmd = "pg_dump -U #{user} "
        cmd += "-p'#{password}'" unless password.nil?
        cmd += " #{database} > #{sqldumpfile}"
      elsif adapter == "sqlite3"
        msg "Using Sqlite3 -- dumping using sql."
        dbfile = File.join(RAILS_APPDIR, database)
        cmd = "sqlite3 #{dbfile} '.dump' > #{sqldumpfile}"
      else
        raise("Database Dump Failed: Unknown adapter")
      end
      # hide password in the message
      msg "Executing: #{cmd.gsub /-p'.*'/, "[hidden]"}"
      result = system(cmd)
      if result
        msg "Database dumped to #{sqldumpfile}."
      else
        raise("Database dump failed: #{$?}")
      end
    end

    desc "Dump Environment's Database to the backup directory in a format that can be grokked by Sqlite3"
    task :dumpsqlite3 do
      archivedir, backupdir, sqldumpfile, dirs = retrive_backup_config

      unless File.fnmatch(File::SEPARATOR+"*", sqldumpfile)
        sqldumpfile = File.join(backupdir, sqldumpfile)
      end

      msg "Chdir to #{RAILS_APPDIR}"
      FileUtils.chdir(RAILS_APPDIR)
      FileUtils.mkdir_p(backupdir)
      msg "Retriving Database Configuration."
      adapter, database, user, password = retrieve_db_info

      msg "Dumping database."
      if adapter == "mysql"
        msg "Using MySql."
        cmd = "mysqldump --no-create-db --no-create-info --extended-insert=0  -u #{user} "
        cmd += "-p'#{password}'" unless password.nil?
        cmd += " #{database} | grep INSERT | sed s/\\\`/\\\"/g > #{sqldumpfile}"
      elsif adapter == "sqlite3"
        msg "Using Sqlite3 -- dumping using sql."
        dbfile = File.join(RAILS_APPDIR, database)
        cmd = "sqlite3 #{dbfile} '.dump' > #{sqldumpfile}"
      else
        raise("Database Dump Failed: Unknown adapter")
      end
      # hide password in the message
      msg "Executing: #{cmd.gsub /-p'.*'/, "[hidden]"}"
      result = system(cmd)
      if result
        msg "Database dumped to #{sqldumpfile}."
      else
        raise("Database dump failed: #{$?}")
      end
    end


    desc "Archive dumped database and directories to TAR archive file."
    task :archive do
      archivedir, backupdir, sqldumpfile, dirs = retrive_backup_config
      unless File.fnmatch(File::SEPARATOR+"*", sqldumpfile)
        sqldumpfile = File.join(backupdir, sqldumpfile)
      end
      archive_filename = "#{RAILS_ENV}_backup_#{Time.now.strftime("%B.%d.%Y_at_%I.%M.%S%p_%Z")}.tar.gz"

      msg "Chdir #{RAILS_APPDIR}"
      if !File.exists?(sqldumpfile)
        raise "Archive failed: SQL dumpfile #{sqldumpfile} does not exist."
      end

      FileUtils.chdir(RAILS_APPDIR)
      FileUtils.mkdir_p(archivedir)
      archivefile = File.join(archivedir,archive_filename)
      # We need "h" because /current/public/* has symbolic links to /releases/public/*
      cmd = "tar chfz #{archivefile} --ignore-failed-read #{sqldumpfile} #{dirs.join(" ")}"
      msg "Executing: #{cmd}"
      result = system(cmd)
      if result
        msg "Archived to #{archivefile}"
      else
        raise "Archive failed: #{$?}"
      end
    end

    desc "Restore archive to environment"
    task :restore do
      unless ENV.include?("ARCHIVE")
        raise "usage: rake backup:restore ARCHIVE=production.tar.gz"
      end

      msg "Chdir #{RAILS_APPDIR}"
      FileUtils.chdir(RAILS_APPDIR)

      cmd = "tar -x -z --ignore-failed-read -f #{ENV['ARCHIVE']}"
      msg "Executing: #{cmd}"
      result = system(cmd)
#       if !result
#         raise "Archive Extraction Failed #{$?}"
#       end
      msg "Archive has been extracted."

      archivedir, backupdir, sqldumpfile, dirs = retrive_backup_config
      unless File.fnmatch(File::SEPARATOR+"*", sqldumpfile)
        sqldumpfile = File.join(backupdir, sqldumpfile)
      end
      if !File.exists?(sqldumpfile)
         msg "We just corruptted the public directories during the extraction."
        raise "Archive Extraction failed: SQL dumpfile #{sqldumpfile} does not exist."
      end
      msg "Retriving Database Configuration."
      adapter, database, user, password = retrieve_db_info

      msg "Restoring database."
      if adapter == "mysql"
        msg "Using MySql."
        cmd = "mysqlimport --opt --skip-add-locks --quote-names --max-allowed-packet=600M -u #{user} "
        cmd += "-p'#{password}'" unless password.nil?
        cmd += " #{database} > #{sqldumpfile}"
      elsif adapter == "postgresql"
        msg "Using Postgres -- this is untested."
        cmd = "psql -U #{user} "
        cmd += "-p'#{password}'" unless password.nil?
        cmd += " #{database} < #{sqldumpfile}"
      elsif adapter == "sqlite3"
        dbfile = File.join(RAILS_APPDIR, database)
        msg "Using Sqlite3 -- removing #{dbfile}."
        cmd = "cat #{sqldumpfile} | grep INSERT | sed s/\\\`/\\\"/ | sqlite3 #{dbfile}"
      else
        raise("Database Restore Failed: Unknown adapter")
      end
      # hide password in the message
      msg "Executing: #{cmd.gsub /-p'.*'/, "[hidden]"}"
      result = system(cmd)
      if result
        msg "Database restored from #{sqldumpfile}."
      else
        raise("Database restore failed: #{$?}")
      end
    end
end
