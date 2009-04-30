class CreateClubTripRegistrationsConfigurations < ActiveRecord::Migration
  def self.up
    create_table :club_trip_registrations_configurations do |t|
      t.text   :notification_email

      t.timestamps
    end
  end

  def self.down
    drop_table :club_trip_registrations_configurations
  end
end
