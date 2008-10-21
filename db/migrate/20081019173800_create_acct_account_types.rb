class CreateAcctAccountTypes < ActiveRecord::Migration
  def self.up
    create_table :acct_account_types do |t|
      t.string     :name
      t.text       :description, :default => ""

      t.timestamps
    end
  end

  def self.down
    drop_table :acct_account_types
  end
end
