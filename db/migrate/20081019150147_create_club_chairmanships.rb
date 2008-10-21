class CreateClubChairmanships < ActiveRecord::Migration
  def self.up
    create_table :club_chairmanships do |t|
      t.string      :name
      t.text        :description, :default => ""
      
      t.timestamps
    end
  end

  def self.down
    drop_table :club_chairmanships
  end
end
