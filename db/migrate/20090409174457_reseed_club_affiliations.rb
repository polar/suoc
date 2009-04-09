class ReseedClubAffiliations < ActiveRecord::Migration
  def self.up
    load(RAILS_ROOT+"/db/bootstrap/003_seed.rb")
  end

  def self.down
  end
end
