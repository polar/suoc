namespace :db do

  desc "Backs up the database to an archive."
  task :backup do
    msg "Backing up #{RAILS_ENV} database"
    archive = backup
    msg "Backed up to #{archive}"
  end

  desc "Make a production back up and bring it to staging."
  task :stage do
    msg "Backing up production database"
    if RAILS_ENV == "staging"
      archive = backup("production")
      restore_db(archive)
    else
      msg "Not in staging environment"
    end
  end

end

  def restore_db(archive)
     adapter, database, user, password = retrieve_db_info
     if adapter == "mysql"
       cmd = "mysql -u #{user}"
       cmd += " -p'#{password}' " unless password.nil?
       cmd += " #{database} < #{archive}"
       result = system(cmd)
       raise("database restore failed.  msg: #{$?}") unless result
     else
       raise("unsupported adapter #{adapter}: #($?)")
     end
  end

  def backup(db = RAILS_ENV)
    archive = "/tmp/#{archive_name(RAILS_ENV,'db')}"
    adapter, database, user, password = retrieve_db_info
    if adapter == "mysql"
      cmd = "mysqldump --opt --skip-add-locks --quote-names --max-allowed-packet=600M -u #{user} "
    elsif adapter == "postgresql"
      cmd = "/usr/local/pgsql/bin/pg_dump -U #{user} "
    else
      raise("database dump failed.  msg: unknown adapter")
    end
    cmd += " -p'#{password}' " unless password.nil?
    cmd += " #{database} > #{archive}"
    result = system(cmd)
    raise("database dump failed.  msg: #{$?}") unless result
    return archive
  end

  def retrieve_db_info
    # read the remote database file....
    # there must be a better way to do this...
    result = File.read "#{RAILS_ROOT}/config/database.yml"
    result.strip!
    config_file = YAML::load(ERB.new(result).result)
    return [
       config_file[RAILS_ENV]['adapter'],
       config_file[RAILS_ENV]['database'],
       config_file[RAILS_ENV]['username'],
       config_file[RAILS_ENV]['password']
      ]
  end
                                                
  def archive_name(env,name)
    @timestamp ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
    token(name).sub('_', '.') + ".#{env}.#{@timestamp}"
  end

  def token(name)
    "#{project_name}_#{ENV['INCREMENT'] ? "#{ENV['INCREMENT']}_" : ""}#{name}"
  end


