class CreateClubAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :club_announcements do |t|
      t.string     :dates,   :default => ""
      t.string     :what,    :default => ""
      t.string     :contact, :default => ""
      t.timestamps
    end
  end

  def self.down
    drop_table :club_announcements
  end
end
