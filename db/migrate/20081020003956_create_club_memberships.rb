class CreateClubMemberships < ActiveRecord::Migration
  def self.up
    create_table :club_memberships do |t|
      t.references :member        # ClubMember
      t.integer    :member_type,  # ClubMembershipType
                   :default => 0     # Zero will always be default
      t.references :transaction   # AcctTransaction
      t.integer    :year

      t.timestamps
    end
  end

  def self.down
    drop_table :club_memberships
  end
end
