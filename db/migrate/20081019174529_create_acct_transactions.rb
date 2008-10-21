class CreateAcctTransactions < ActiveRecord::Migration
  def self.up
    create_table :acct_transactions do |t|
            t.references :recorded_by         # user
            t.references :target_account
            t.references :acct_action
            t.string     :description
            t.date       :date
            t.decimal    :amount, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :acct_transactions
  end
end
