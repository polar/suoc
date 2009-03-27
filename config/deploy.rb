require 'palmtree/recipes/mongrel_cluster'
require 'capistrano/ext/multistage'

set :default_stage, "staging"

#
# We know the production path for getting the
# assets from production to staging.
#
set :PRODUCTION_PATH, "/var/www/suoc/current"

set :gateway, "polar@adiron.kicks-ass.net:922"

#
# Git Configuration
#
set :scm,          "git"
set :scm_username, "polar"
set :repository,   "git://github.com/polar/suoc.git"

#
# Do not use sudo and use user "deploy"
#
set :use_sudo, false
set :user, "deploy"


#
# Multistage Defaults
#
#set :stage_dir, "config/deploy"
#   The following gets evaluation delayed.
#set(:mongrel_conf) { "#{current_path}/config/deploy/#{stage}/mongrel_cluster.yml" }


# Custom Tasks
namespace :deploy do

  desc "Copying the right config files and sym links for the current stage environment."
  task :after_default do

    # Move environment-specific configs into config directory.
    %w{mongrel_cluster.yml}.each do |file|
      run "cp #{release_path}/config/deploy/#{rails_env}/#{file} #{release_path}/config/#{file}"
    end     
  
    # Move forward uploads and index directories along with new release.
    %w{images}.each do |share|
      run "rm -rf #{release_path}/public/#{share}"
      run "rm -rf #{release_path}/#{share}"
      run "mkdir -p #{shared_path}/system/#{share}"
      run "ln -s #{shared_path}/system/#{share} #{release_path}/public/#{share}"
    end  
  
    cleanup
  end

  desc "Transfer db and assests from production to staging."
  task :after_finalize_update do
    if rails_env == "staging"
      run "cd #{release_path}; rake RAILS_ENV=staging db:stage"
      dirsymlink(File.join(PRODUCTION_PATH,"public"),File.join(release_path,"public")) 
    end
  end

  desc "Restart the Mongrel processes on the app server by calling restart_mongrel_cluster. "
  task :restart, :roles => :app do 
    restart_mongrel_cluster 
  end 
  
  desc "Start Mongrel processes on the app server. "
  task :start_mongrel_cluster , :roles => :app do 
    sudo "/usr/sbin/monit start all -g #{monit_group}" 
  end 
  
  desc "Restart the Mongrel processes on the app server by starting and stopping the cluster." 
  task :restart_mongrel_cluster , :roles => :app do 
    sudo "/usr/sbin/monit restart all -g #{monit_group}" 
  end 
  
  desc "Stop the Mongrel processes on the app server." 
  task :stop_mongrel_cluster , :roles => :app do 
    sudo "/usr/sbin/monit stop all -g #{monit_group}" 
  end 

  desc "Place the maintenance page out into the public path."
  task :disable_web, :roles => :web, :except => { :no_release => true } do
    require 'erb'
    on_rollback { run "rm #{shared_path}/system/maintenance.html" }

    reason = ENV['REASON']
    deadline = ENV['UNTIL']

    template = File.read(File.join(File.dirname(__FILE__), "templates", "maintenance.html.erb"))
    result = ERB.new(template).result(binding)

    put result, "#{shared_path}/system/maintenance.html", :mode => 0644
  end  
  
  desc "Analyze Rails Log instantaneously" 
  task :pl_analyze, :roles => :app do
    run "pl_analyze #{shared_path}/log/#{rails_env}.log" do |ch, st, data|
      print data
    end
  end

  desc "Run rails_stat" 
  task :rails_stat, :roles => :app do
    stream "rails_stat #{shared_path}/log/#{rails_env}.log" 
  end  
end


#
# This class extends the Dir class to get the
# full paths for each of its entries.
#
class ExtDir < Dir
  def entry_paths
    entries.map {|e| File.join(path,e)}
  end
end

#
# This method recursively descends the first directory
# cloning it in d2 by makeing directories, and symlinks
# to entries in d1
#
def dirsymlink(d1,d2)
  if !File.directory?(d1)
    raise "Not a directory: #{d1}"
  end
  if !File.directory?(d2)
    if !File.exists?(d2)
      Dir.mkdir(d2)
    else
      # Just ignore conflicts
      puts "conflict: Not a directory: #{d2}"
      return
    end
  end
  dir = ExtDir.open(d1)
  dir.entry_paths.each do |path|
   if File.basename(path) != "." && File.basename(path) != ".."
     if File.directory?(path)
       dirsymlink(path,File.join(d2,File.basename(path)))
     else
       f2 = File.join(d2,File.basename(path))
       if !File.exists?(f2)
       	 File.symlink(path,f2)
       end
     end
   end
  end
end
  

