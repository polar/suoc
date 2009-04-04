class CreateClubTrips < ActiveRecord::Migration
  def self.up
    create_table :club_trips do |t|
      t.string :trip
      # when is a reserved word, we use swhen
      t.string :swhen 
      t.string :where 
      t.string :meet 
      t.string :e_room 
      t.string :limit 
      t.string :leader
      t.string :contact
      t.timestamps
    end
  end

  def self.down
    drop_table :club_trips
  end
end
