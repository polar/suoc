require 'palmtree/recipes/mongrel_cluster'
require 'capistrano/ext/multistage'

#set :stages, %w(staging production)
set :default_stage, "staging"

#set :application, "suoc"
#set :deploy_to, "/var/www/#{application}"

set :gateway, "polar@adiron.kicks-ass.net:922"

# Git Configuration
set :scm, "git"
set :scm_username, "polar"
set :repository,  "git://github.com/polar/suoc.git"

set :use_sudo, false
set :user, "deploy"


# Application directory.
set :stage_dir, "config/deploy"

set(:mongrel_conf) { "#{current_path}/config/deploy/#{stage}/mongrel_cluster.yml" }


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



