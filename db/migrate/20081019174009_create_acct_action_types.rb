class CreateAcctActionTypes < ActiveRecord::Migration
  def self.up
    create_table :acct_action_types do |t|
      t.string     :name
      t.text       :description, :default => ""

      t.timestamps
    end
  end

  def self.down
    drop_table :acct_action_types
  end
end
