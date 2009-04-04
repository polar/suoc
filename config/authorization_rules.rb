privileges do
  # I assume we have :read, :create, :update, :delete
  # This privilege has only meaning in the context
  # of a User/ClubMember and allows the display of
  # the club_memberid attribute.
  privilege :read_id
  privilege :write_id, :includes => :read_id
end


authorization do
  role :admin do
    #
    # Declarative Authorization, available in 
    #  developement mode.
    #
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :authorization_usages, :to => :read
    
    #
    # An Admin may read the ClubMember.club_memberid
    #
    has_permission_on :users, :to => :write_id 
    has_permission_on :users, :to => :write
    has_permission_on :club_trips, :to => :create
  end
  role :member do
    includes :guest
    # Note: ClubMembers' table names is "users"
    # So to write rules for ClubMembers we must use :users.
    has_permission_on :users, :to => :write do
      if_attribute :id => is {user.id}
    end
    has_permission_on :users, :to => :write_id do
      if_attribute :id => is {user.id}
    end
    has_permission_on :club_trips, :to => [:read]
    has_permission_on :club_trips, :to => [:create,:update,:delete] do
      is {user.current_officers || user.current_leaders || user.current_chairs}
    end
  end
  
  role :guest do
  end

end
