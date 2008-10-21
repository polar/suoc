class CreateClubMembershipTypes < ActiveRecord::Migration
  def self.up
    create_table :club_membership_types do |t|
      t.string      :name
      t.string      :description, :default => ""
      
      t.timestamps
    end
  end

  def self.down
    drop_table :club_membership_types
  end
end
