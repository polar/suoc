set :application, "suoc"
set :repository,  "git://github.com/polar/suoc.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git

set :scm_username, "polar"

set :gateway, "suoc.syr.edu:922"
set :user, "suoc"

role :app, "rails.local"
role :web, "rails.local"
role :db,  "rails.local", :primary => true
