class CreateAcctAccountsAcctActions < ActiveRecord::Migration
  def self.up
     create_table :acct_accounts_acct_actions, :id => false do |t|
       t.references :acct_account
       t.references :acct_action
    end
  end

  def self.down
    drop_table :acct_accounts_acct_actions
  end
end
