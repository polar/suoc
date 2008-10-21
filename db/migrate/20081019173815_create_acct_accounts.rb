class CreateAcctAccounts < ActiveRecord::Migration
  def self.up
    create_table :acct_accounts do |t|
      t.string     :name
      t.text       :description, :default => ""
      t.references :account_type

      t.timestamps
    end
  end

  def self.down
    drop_table :acct_accounts
  end
end
