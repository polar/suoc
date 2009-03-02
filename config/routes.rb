ActionController::Routing::Routes.draw do |map|
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

  map.resource :club_dashboard
  map.resource :eroom_ledger, :member => {
    :auto_complete_for_club_member_login => :post,
    :update_transaction => :post,
    :update_description_form => :post}

  map.resources :treasurer_ledger, :member => {
    :update_transaction => :put,
    :update_description_form => :get}


  
  
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

  # We need the sign up route earler so that we can use club_members
  map.from_plugin :community_engine
  map.resources :users, :member => {
    :edit_club_member_info_user => :post
  }

  # We need it after so that the named route "singup-path" is cool.
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

# Replace the controller for the "users" routes with "club_members".
# This requires changing the "requirements" and "defaults" hashes
# for each route. Then, for named routes that manage things
# like "users_url", we must regenerate the helpers.
#
#ActionController::Routing::Routes.routes.each do |r|
#  if r.requirements[:controller] == "users"
#    r.requirements[:controller] = "club_members"
#    r.defaults[:controller] = "club_members"
#    # rewrite the generation function.
#    r.write_generation
#  end
#end
# Regnerate the Helper functions so that the *user_url functions work
# correctly.
#
# The second argument is "regenerate_code", which we must set.to true.
# The ActionController::Base aand ActionView:Base are the destinations for the
# created helper methods, and is the default for this function.
#ActionController::Routing::Routes.install_helpers [ActionController::Base, ActionView::Base], true

