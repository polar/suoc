class CreateAcctLedgers < ActiveRecord::Migration
  def self.up
    create_table :acct_ledgers do |t|
      t.text            :name
      t.text            :slug
      t.text            :description
      t.references      :target_account
      t.text            :subtotal_label
      t.text            :total_label

      t.timestamps
    end
  end

  def self.down
    drop_table :acct_ledgers
  end
end
