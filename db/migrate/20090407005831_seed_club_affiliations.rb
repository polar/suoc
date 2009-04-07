class SeedClubAffiliations < ActiveRecord::Migration
  def self.up
    load(RAILS_ROOT+"/db/bootstrap/002_seed.rb")
  end

  def self.down
  end
end
