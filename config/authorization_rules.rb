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

  # For club trip registrations
  privilege :add_remove

  #
  # This privilege is specifically for the ledgers controller, which
  # may be read by anybody, but only such may be able to modify or
  # add transactions.
  #
  privilege :manage_transactions
end


authorization do
  role :admin do
    includes :ops_admin
    includes :config_admin

    #
    # Declarative Authorization, available in
    #  developement mode.
    #
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :authorization_usages, :to => :read

    #
    # An Admin may read,write the ClubMember.club_memberid
    #
    has_permission_on :users, :to => :write_id
    has_permission_on :acct_transactions, :to => :delete
  end

  #
  role :config_admin do
    has_permission_on :users, :to => :manage
    has_permission_on :acct_accounts, :to => :manage
    has_permission_on :acct_actions, :to => :manage
    has_permission_on :acct_categories, :to => :manage
    has_permission_on :acct_action_types, :to => :manage
    has_permission_on :acct_account_types, :to => :manage
    has_permission_on :acct_ledgers, :to => :manage
  end

  #
  # The :trip_admin is allowed to manage Trips Going Out
  # table through the :club_trips controller.
  #
  role :trip_admin do
    has_permission_on :club_trips, :to => :manage
  end

  #
  # The :announcement_admin is allowed to manage Announcements
  # table through the :club_announcements controller.
  #
  role :announcement_admin do
    has_permission_on :club_announcements, :to => :manage
  end

  #
  # The :pages_admin is allowed to manage the Comatose
  # Home Pages.
  # TODO: Role:PagesAdmin Not yet implemented.
  role :pages_admin do
    has_permission_on :comatose_admin, :to => :manage
  end

  #
  # The :ledgers_admin is allowed to manage creation
  # and deletion of ledgers.
  role :ledgers_admin do
    has_permission_on :acct_ledgers, :to => :manage
  end

  #
  # Ledger Transactor is an operations role in which the operator
  # may delete or add transactions to a ledger.
  #
  role :ledger_transactor do
    has_permission_on :acct_ledgers, :to => [:read, :manage_transactions]
    has_permission_on :acct_transactions, :to => :delete do
      if_attribute :recorded_by => is {user}
    end
  end

  #
  # This role is given to people who have privileges over operations.
  #
  role :ops_admin do
    includes :trip_admin
    includes :announcement_admin
    includes :pages_admin
    includes :ledger_transactor
  end
  #
  # Basically, Current Officers, Chairs, and Leaders
  # are allowed to manage the operations of the club,
  # but not the configuation.
  #
  role :officer do
    includes :ops_admin
  end
  role :chair do
    includes :ops_admin
  end
  role :leader do
    includes :ops_admin
    has_permission_on :club_trip_registrations, :to => [:create]
    has_permission_on :club_trip_registrations, :to => [:update,:delete] do
      if_attribute :leader_id => is {user.id}
    end
  end

  #
  # The role :member is assigned once the user successfully
  # activates their account.
  #
  role :member do
    includes :guest
    # Note: ClubMember table is an extension of User.
    # We use the UsersController to hand its operations.
    # So to write rules for ClubMembers we must use :users.
    has_permission_on :users, :to => :write do
      if_attribute :id => is {user.id}
    end
    has_permission_on :users, :to => :write_id do
      if_attribute :id => is {user.id}
    end
    has_permission_on :club_trip_registrations, :to => [:read,:add_remove]
  end

  #
  # The Default Role.
  #   Can read the documents page.
  #   The trips list and announcments are available on the
  #   Home pages.
  #
  role :guest do
    has_permission_on :club_documents, :to => [:read]
  end

end
