ActionController::Routing::Routes.draw do |map|
  map.resources :payments

  map.resource  :reunion, :controller => "reunion"
  map.resources :acct_action_sets
  map.resources :acct_reports

  map.resources :club_memberships, :collection => {
    :submit_list => :post }

  map.resources :cert_member_certs

  map.resources :cert_orgs, :member => {
      :auto_complete_for_cert_org_name => :post
  }

  map.resources :cert_types

  map.resources :club_login_messages

  map.resources :club_trip_registrations, :collection => {
    :statistics => :get,
    :list_submitted => :get,
    :configure => :get,
    :update_configuration => :post}

  map.resources :acct_ledgers

  map.resources :club_ledgers

  map.resources :club_announcements

  map.resources :club_documents
  map.resources :club_affiliations

  map.resources :page_photos

  map.admin_dashboard   '/admin/dashboard', :controller => 'comatose_admin', :action => 'index'

  map.comatose_admin

  map.comatose_root 'home'

  map.resources :club_members
  map.resources :acct_account_types
  map.resources :acct_accounts
  map.resources :acct_action_types
  map.resources :acct_categories
  map.resources :acct_actions
  map.resources :club_activities
  map.resources :club_offices
  map.resources :club_officers
  map.resources :club_chairs
  map.resources :club_leaderships
  map.resources :club_leaders
  map.resources :club_member_statuses
  map.resources :club_trips

  map.resource :club_dashboard
  map.resource :eroom_ledger, :member => {
    :auto_complete_for_club_member_login => :post,
    :update_transaction => :post,
    :update_description_form => :post}

  map.resource :treasurer_ledger, :member => {
    :auto_complete_for_club_member_login => :post,
    :update_transaction => :post,
    :update_description_form => :post}

  map.resources :cert_certifications


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs toller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  #
  # This doesn't seem to work automatically or
  # explicitly. We have to copy the routing rules
  # from Declarative Authorization here. Grrrrr..
  #
  #map.from_plugin :declarative_authorization
  map.resources :authorization_rules,
                :only => :index,
                :collection => {:graph => :get}
  map.resources :authorization_usages,
                :only => :index
  # We need the sign up route earlier so that we can use club_members
  map.from_plugin :community_engine

  map.resources :users, :member => {
    :edit_club_member_info_user => :post
  }

  # We need it after so that the named route "singup-path" is cool.
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
