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

role :app, "deploy@suoc.syr.edu:922"
role :web, "deploy@suoc.syr.edu:922"
role :db,  "deploy@suoc.syr.edu:922", :primary => true
