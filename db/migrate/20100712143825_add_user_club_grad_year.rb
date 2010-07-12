class AddUserClubGradYear < ActiveRecord::Migration
  def self.up
    change_table "users" do |t|
      t.date :club_grad_year
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :club_grad_year
    end
  end
end
