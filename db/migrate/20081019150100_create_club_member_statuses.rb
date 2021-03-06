class CreateClubMemberStatuses < ActiveRecord::Migration
  def self.up
    create_table :club_member_statuses do |t|
      t.string      :name
      t.text        :description, :default => ""
      
      t.timestamps
    end
  end

  def self.down
    drop_table :club_member_statuses
  end
end
