namespace :db do
  desc "Backs up the database to an archive"
  task :backup do
     cmd = "mysqldump --opt --skip-add-locks --quote-names" 
      msg "Backing up Database"
      archive = "/tmp/#{archive_name('db')}"

      msg "retrieving db info"
      adapter, database, user, password = retrieve_db_info
      msg "#{retrieve_db_info}"

      msg "dumping db"
      if adapter == "mysql"
        cmd = "mysqldump --opt --skip-add-locks --max-allowed-packet=600M -u #{user} "
      elsif adapter == "postgresql"
        cmd = "/usr/local/pgsql/bin/pg_dump -U #{user} "
      else
        raise("database dump failed.  msg: unknown adapter")
      end
      puts cmd + "... [password filtered]"
      cmd += " -p'#{password}' " unless password.nil?
      cmd += " #{database} > #{archive}"
      result = system(cmd)
      raise("database dump failed.  msg: #{$?}") unless result
  end
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
                                                
  def archive_name(name)
    @timestamp ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
    token(name).sub('_', '.') + ".#{RAILS_ENV}.#{@timestamp}"
  end

  def token(name)
    "#{project_name}_#{ENV['INCREMENT'] ? "#{ENV['INCREMENT']}_" : ""}#{name}"
  end


