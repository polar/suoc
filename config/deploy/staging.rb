set :application, "suoc_staging"
set :repository,  "git://github.com/polar/suoc.git"
set :git_enable_submodules, 1

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/suoc_staging"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git

set :use_sudo, false

set :scm_username, "polar"

set :gateway, "polar@adiron.kicks-ass.net:922"
set :user, "deploy"

set :rails_env, "staging"
set :monit_group, "suoc"

# WHAT THE FUCK IS THIS???
# Why isn't this :app_user, or something logical?
#set :runner, "suoc"

#
# A nice litte find off of some stupid blog.
#
#set :db_database, "suoc_production"
#set :db_user, "root"
#set :db_password, "root"

role :app, "deploy@rails.local"
role :web, "deploy@rails.local"
role :db,  "deploy@rails.local", :primary => true
