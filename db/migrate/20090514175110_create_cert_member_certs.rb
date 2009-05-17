class CreateCertMemberCerts < ActiveRecord::Migration
  def self.up
    create_table :cert_member_certs do |t|
      t.references    :cert_org
      t.references    :member
      t.date          :start_date
      t.date          :end_date
      t.text          :comment
      t.references    :verified_by
      t.date          :verified_date

      t.timestamps
    end
  end

  def self.down
    drop_table :cert_member_certs
  end
end
