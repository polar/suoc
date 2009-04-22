class CreateAcctLedgerAccounts < ActiveRecord::Migration
  def self.up
    create_table :acct_ledger_accounts do |t|
      t.text            :label
      t.references      :account
      t.references      :ledger
      t.boolean         :show_if_zero
      t.integer         :balances_in
      t.integer         :position

      t.timestamps
    end
  end

  def self.down
    drop_table :acct_ledger_accounts
  end
end
