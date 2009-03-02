class CreateClubActivities < ActiveRecord::Migration
  def self.up
    create_table :club_activities do |t|
      t.string      :name
      t.text        :description, :default => ""
      t.text        :tagline, :default => ""
      t.integer     :position

      t.timestamps
    end
  end

  def self.down
    drop_table :club_activities
  end
end
