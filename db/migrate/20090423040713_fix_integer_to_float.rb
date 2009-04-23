class FixIntegerToFloat < ActiveRecord::Migration
  def self.up
    change_column :acct_entries, :debit, :decimal, :precision => 12, :scale => 2
    change_column :acct_entries, :credit, :decimal, :precision => 12, :scale => 2
    change_column :acct_ledger_accounts, :balances_in, :boolean
    change_column :acct_transactions, :amount, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    change_column :acct_entries, :debit, :decimal, :precision => 10, :scale => 0
    change_column :acct_entries, :credit, :decimal, :precision => 10, :scale => 0
    change_column :acct_ledger_accounts, :balances_in, :integer
    change_column :acct_transactions, :amount, :decimal, :precision => 10, :scale => 0
  end
end
