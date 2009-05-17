class CreateCertOrgs < ActiveRecord::Migration
  def self.up
    create_table :cert_orgs do |t|
      t.text         :name
      t.text         :description, :default => ""
      t.integer      :position
      t.references   :cert_type

      t.timestamps
    end
  end

  def self.down
    drop_table :cert_orgs
  end
end
