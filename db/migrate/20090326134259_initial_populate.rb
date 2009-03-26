class InitialPopulate < ActiveRecord::Migration
  def self.up
    load(File(RAILS_ROOT+'/db/bootstrap/001_seed.rb'))
  end

  def self.down
  end
end
