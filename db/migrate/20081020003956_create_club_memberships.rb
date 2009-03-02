class CreateClubMemberships < ActiveRecord::Migration
  def self.up
    create_table :club_memberships do |t|
      t.references :member        # ClubMember
      t.references :member_type,  # ClubMembershipType
                   :default => 0     # Zero will always be default
      # Gotcha: calling a field a transaction is a bad idea.
      #t.references :transaction   # AcctTransaction
      t.references :acct_transaction   # AcctTransaction
      t.integer    :year

      t.timestamps
    end
  end

  def self.down
    drop_table :club_memberships
  end
end
