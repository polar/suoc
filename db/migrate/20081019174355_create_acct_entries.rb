class CreateAcctEntries < ActiveRecord::Migration
  def self.up
    create_table :acct_entries do |t|
      # Gotcha: Calling a field "transaction" is a bad idea.
      #t.references  :transaction # AcctTransaction
      t.references  :acct_transaction # AcctTransaction
      t.references  :account     # AccAccount
      t.references  :category    # AcctCategory
      t.decimal     :debit,  :default => 0
      t.decimal     :credit, :default => 0
      t.string      :description
      t.references  :recorded_by # ClubMember
      t.date        :date

      t.timestamps
    end
  end

  def self.down
    drop_table :acct_entries
  end
end
