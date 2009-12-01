class AddReportsToAcctAccount < ActiveRecord::Migration
  def self.up
    change_table :acct_accounts do |t|
      t.boolean  :reports, :default => true
    end
  end

  def self.down
    change_table :acct_accounts do |t|
      t.remove   :reports
    end
  end
end
