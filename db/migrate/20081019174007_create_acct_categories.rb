class CreateAcctCategories < ActiveRecord::Migration
  def self.up
    create_table :acct_categories do |t|
      t.string     :name
      t.text       :description, :default => ""

      t.timestamps
    end
  end

  def self.down
    drop_table :acct_categories
  end
end
