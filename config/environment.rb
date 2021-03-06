# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  #config.gem "active_merchant"

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  #
  # Engines must go first here.
  #
  config.plugins = [ :engines,
                     :community_engine,
                     :comatose_engine,
                     :declarative_authorization,
                     :white_list,
                     :all ]

  # Not all plugins play nice when loaded twice (PaginatingFind). We create
  # a directory "engine_plugins" in which it contains symbolic links to
  # all plugins in each engine_plugins directory, thereby only having it
  # listed once.
  #  cd vendor/engine_plugins; ln -sf ../plugins/*_engine/engine_plugins/* .
  config.plugin_paths += ["#{RAILS_ROOT}/vendor/engine_plugins"]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'Eastern Time (US & Canada)'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_suoc_session',
    :secret      => 'd440fce61e1a094640b66c115d38b133479c066f0e49325056efaa0767d583abf6b1387bc0cd8a265ce92b05a583da9f1f7f4f3a2cea11399b5de085a4cde959'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end

require "#{RAILS_ROOT}/vendor/plugins/comatose_engine/engine_config/boot.rb"
require "#{RAILS_ROOT}/vendor/plugins/community_engine/engine_config/boot.rb"

#
# Validates Dates Time plugin.
#   We need to accept month/day/year. Default is day/month/year.
ActiveRecord::Validations::DateTime.us_date_format = true

#
# This horse hockey is because Community Engine keeps all the
# the authentication stuff in BaseController and not Application
# Controller and the Declarative Authorization Plugin requires it
# to be in ApplicationController.
# We created a "base_module.rb" with all the methods of BaseController
# and insert the filters.
# Note: We had to explicity add the BaseHelper as this gets loaded
# automatically into the BaseController by Rails.
#
AuthorizationRulesController.send :include, AuthenticatedSystem
AuthorizationRulesController.send :include, LocalizedApplication
AuthorizationRulesController.send :include, BaseModule
AuthorizationRulesController.send :around_filter, :set_locale
AuthorizationRulesController.send :before_filter, :login_from_cookie
AuthorizationRulesController.send :skip_before_filter, :verify_authenticity_token, :only => :footer_content
AuthorizationRulesController.send :helper, BaseHelper
AuthorizationRulesController.send :helper_method, :commentable_url
AuthorizationRulesController.send :caches_action, :site_index, :footer_content, :if => Proc.new{|c| c.cache_action? }


AuthorizationUsagesController.send :include, AuthenticatedSystem
AuthorizationUsagesController.send :include, LocalizedApplication
AuthorizationUsagesController.send :include, BaseModule
AuthorizationUsagesController.send :around_filter, :set_locale
AuthorizationUsagesController.send :before_filter, :login_from_cookie
AuthorizationUsagesController.send :skip_before_filter, :verify_authenticity_token, :only => :footer_content
AuthorizationUsagesController.send :helper, BaseHelper
AuthorizationUsagesController.send :helper_method, :commentable_url
AuthorizationUsagesController.send :caches_action, :site_index, :footer_content, :if => Proc.new{|c| c.cache_action? }


Comatose.configure do |config|
  # We are going to get rid of caching so our
  # trips and annoucements pages work.
  # Apparently, keyword "nocache" doesn't work.
  # The keyword stops generating of static pages in "/public".
  # However, I believe caching is happening in memory, which
  # doesn't follow nocache.
  config.disable_caching = true

 # We handle authorization now using the Engines Plugin architecture
 # allowing us to add filters and override methods in the
 # ComatoseAdminController.
#
#   # Includes AuthenticationSystem in the ComatoseAdminController
#   config.admin_includes << :authenticated_system
#
#   # Calls :login_required as a before_filter
#   config.admin_authorization = :admin_required
#
#   # Returns different 'root paths'
#   config.admin_get_root_page do
#
#     if current_user.role == 'XXXX' # This depends on your system
#       ComatosePage.find_by_path( 'site/help' )
#
#     elsif current_user.role == 'YYYY'
#       # Returns multiple 'roots'
#       [
#         ComatosePage.find_by_path( 'site/help' ),
#         ComatosePage.find_by_path( 'app/faq' )
#       ]
#
#     else
#       ComatosePage.root
#
#     end
#   end
end
