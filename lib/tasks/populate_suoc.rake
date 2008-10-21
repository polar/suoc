namespace :db do
  desc "Load seed fixtures (from db/suoc_data) into the current environment's database." 
  task :populate_suoc => :environment do
    require 'active_record/fixtures'
    Dir.glob(RAILS_ROOT + '/db/suoc_data/*.yml').each do |file|
      Fixtures.create_fixtures('db/suoc_data', File.basename(file, '.*'))
    end
  end
end
