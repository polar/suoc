class AddUserClubContact < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :club_contact
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :club_contact
    end
  end
end
