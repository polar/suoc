class AddClubUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string     :type       # for table inheritance
      t.string     :club_aliases
      t.string     :club_memberid
      t.date       :club_start_date
      t.date       :club_end_date
      t.references :club_member_status
    end
  end

  def self.down
    change_table :users do |t|
      t.remove               :type
      t.remove               :club_aliases
      t.remove               :club_memberid
      t.remove               :club_start_date
      t.remove               :club_end_date
      t.remove_references    :club_member_status
    end
  end
end
