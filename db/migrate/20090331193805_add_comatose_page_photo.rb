class AddComatosePagePhoto < ActiveRecord::Migration
  def self.up
    change_table :comatose_pages do |t|
      t.references :page_photo
    end
    change_table :comatose_page_versions do |t|
      t.references :page_photo
    end
  end

  def self.down
    change_table :comatose_pages do |t|
      t.remove_references :page_photo
    end
    change_table :comatose_page_versions do |t|
      t.remove_references :page_photo
    end
  end
end
