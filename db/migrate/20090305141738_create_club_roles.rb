class CreateClubRoles < ActiveRecord::Migration
  def self.up
    create_table "club_roles" do |t|
      t.column :title, :string
      t.references :club_member
    end
  end

  def self.down
    drop_table "club_roles"
  end
end
