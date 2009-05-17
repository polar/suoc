class CreateCertTypes < ActiveRecord::Migration
  def self.up
    create_table :cert_types do |t|
      t.text        :name
      t.text        :description
      t.integer     :position

      t.timestamps
    end
  end

  def self.down
    drop_table :cert_types
  end
end
