class CreateAcctActionSets < ActiveRecord::Migration
  def self.up
    create_table :acct_action_sets do |t|
      t.string      :name
      t.string      :description
      t.references  :ledger

      t.timestamps
    end
    # Join table
    create_table :acct_action_sets_acct_actions, :id => false do |t|
      t.references :acct_action
      t.references :acct_action_set
    end
  end

  def self.down
    drop_table :acct_action_sets
    drop_table :acct_action_sets_acct_actions
  end
end
