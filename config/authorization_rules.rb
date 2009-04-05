privileges do

  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read,   :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy

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

  role :trip_admin do
    has_permission_on :club_trips, :to => [:manage]
  end

  role :officer do
    includes :trip_admin
  end
  role :chair do
    includes :trip_admin
  end
  role :leader do
    includes :trip_admin
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
  end
  
  role :guest do
    has_permission_on :club_trips, :to => [:read]
  end

end
