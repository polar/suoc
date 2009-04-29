class CreateClubTripRegistrations < ActiveRecord::Migration
  def self.up
    create_table :club_trip_registrations do |t|
      t.references :leader
      t.references :leadership
      t.text       :email
      t.text       :phone
      t.text       :trip_name
      t.date       :departure_date
      t.date       :return_date
      t.text       :mode_of_transport
      t.text       :location
      t.text       :overnight_location
      t.text       :overnight_phone
      
      t.text       :notes
      t.text       :attendees
      t.date       :submit_date
      t.text       :submit_data

      t.timestamps
    end
  end

  def self.down
    drop_table :club_trip_registrations
  end
end
