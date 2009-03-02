class CreateClubOffices < ActiveRecord::Migration
  def self.up
    create_table :club_offices do |t|
      t.string      :name
      t.text        :description, :default => ""
      t.text        :tagline, :default => ""
      t.integer     :position
      
      t.timestamps
    end
  end

  def self.down
    drop_table :club_offices
  end
end
