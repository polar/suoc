set :application, "suoc"
set :repository,  "git://github.com/polar/suoc.git"
set :git_enable_submodules, 1

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git

set :scm_username, "polar"

set :gateway, "polar@adiron.kicks-ass.net:922"

set :user, "suoc"

# WHAT THE FUCK IS THIS???
set :runner, "suoc"

role :app, "suoc@rails.local:8110"
role :web, "suoc@rails.local:8220"
role :db,  "rails.local", :primary => true
