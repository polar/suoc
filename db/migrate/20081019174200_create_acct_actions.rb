class CreateAcctActions < ActiveRecord::Migration
  def self.up
    create_table :acct_actions do |t|
      t.string     :name
      t.text       :description, :default => ""

      t.references :account     # AcctAccount
      t.references :category    # AcctCategory
      t.references :action_type # AcctActionType

      t.timestamps
    end
  end

  def self.down
    drop_table :acct_actions
  end
end
