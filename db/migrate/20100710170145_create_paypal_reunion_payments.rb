class CreatePaypalReunionPayments < ActiveRecord::Migration
  def self.up
    create_table :paypal_reunion_payments do |t|
      t.references     :member
      t.text           :ipn_data
      t.timestamps
    end
  end

  def self.down
    drop_table :paypal_reunion_payments
  end
end
