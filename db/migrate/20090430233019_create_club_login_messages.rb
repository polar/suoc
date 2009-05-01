class CreateClubLoginMessages < ActiveRecord::Migration
  def self.up
    create_table :club_login_messages do |t|
      t.date        :date
      t.text        :message
      t.references  :author
      t.timestamps
    end
  end

  def self.down
    drop_table :club_login_messages
  end
end
