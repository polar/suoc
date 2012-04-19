privileges do

  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read,   :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy

  privilege :configure

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

  #
  # This privilege is so that officers can be the only ones to view
  # submitted trip registrations
  #
  privilege :show_submitted
  privilege :show_statistics
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
    has_permission_on :users, :to => :verify_cert
    has_permission_on :acct_transactions, :to => :delete
    has_permission_on :club_login_messages, :to => :manage

    has_permission_on :club_leaderships, :to => :manage
    includes :officer
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
    has_permission_on :acct_action_sets, :to => :manage
    has_permission_on :cert_types, :to => :manage
    has_permission_on :cert_orgs, :to => :manage
    has_permission_on :cert_certifications, :to => :manage
    has_permission_on :club_trip_registrations, :to => :configure
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
  # Reports
  #
  role :report_analyzer do
    has_permission_on :acct_reports, :to => [:read]
  end

  #
  # This role is given to people who have privileges over operations.
  #
  role :ops_admin do
    includes :trip_admin
    includes :announcement_admin
    includes :pages_admin
    includes :ledger_transactor
    includes :report_analyzer
  end
  #
  # Basically, Current Officers, Chairs, and Leaders
  # are allowed to manage the operations of the club,
  # but not the configuation.
  #
  role :officer do
    includes :ops_admin
    has_permission_on :club_memberships, :to => [:manage]
    has_permission_on :club_offices, :to => [:manage]
    has_permission_on :club_officers, :to => [:manage]
    has_permission_on :club_trip_registrations, :to => [:show_submitted, :show_statistics]
  end

  role :chair do
    includes :ops_admin
  end
  role :leader do
    includes :ops_admin
    has_permission_on :club_trip_registrations, :to => [:create, :show_statistics]
    has_permission_on :club_trip_registrations, :to => [:update,:delete] do
      if_attribute :leader_id => is {user.id}
    end
  end
  role :leadership_officer do
    has_permission_on :users, :to => [:verify_cert, :delete_cert]
    has_permission_on :cert_member_certs, :to => [:verify]
    has_permission_on :users, :to => [:verify_leader, :delete_leader]
    has_permission_on :club_leaders, :to => [:verify]
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
    has_permission_on :club_login_messages, :to => :read

    has_permission_on :cert_member_certs, :to => [:read]
    has_permission_on :cert_member_certs, :to => [:create,:update,:delete] do
      if_attribute :member_id => is {user.id}
    end

    has_permission_on :club_leaders, :to => [:read]
    has_permission_on :club_leaders, :to => [:create,:update,:delete] do
      if_attribute :member_id => is {user.id}
    end
    has_permission_on :club_offices, :to => [:read]
    has_permission_on :club_officers, :to => [:read]
    has_permission_on :club_officers, :to => [:create,:update,:delete] do
      if_attribute :member_id => is {user.id}
    end
    has_permission_on :club_chairs, :to => [:read]
    has_permission_on :club_chairs, :to => [:create,:update,:delete] do
      if_attribute :member_id => is {user.id}
    end

    has_permission_on :club_leaderships, :to => [:read]
    has_permission_on :club_leaderships, :to => [:create,:update,:delete] do
      if_attribute :member_id => is {user.id}
    end

    has_permission_on :reunion, :to => [:read]
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
