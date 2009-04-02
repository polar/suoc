class CreatePagePhotos < ActiveRecord::Migration
  def self.up
    create_table :page_photos do |t|
      t.string  :filename
      t.string  :content_type
      t.integer :size
      t.integer :width
      t.integer :height
      t.integer :parent_id
      t.string  :thumbnail
      t.timestamps
    end
  end

  def self.down
    drop_table :page_photos
  end
end
