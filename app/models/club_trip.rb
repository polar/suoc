class ClubTrip < ActiveRecord::Base
  require "stringio"
  require "faster_csv"
  
  def self.read(file)
    FasterCSV.parse(file, :headers => true) do |opts|
      t = self.new
      t.trip = opts["Trip"]
      t.swhen = opts["When"]
      t.where = opts["Where"]
      t.meet = opts["Meet"]
      t.e_room = opts["E-Room"]
      t.limit = opts["Limit"]
      t.leader = opts["Leader"]
      t.contact = opts["Contact"]
      t.save
    end
  end
  def self.to_csv
    FasterCSV::Table.new(ClubTrip.all.collect { |x| x.to_csv})
  end
  def self.trip_table
    render :partial => "club_trips/trip_table", :locals => { :club_trips => ClubTrip.all }
  end
  
  def to_csv
    FasterCSV::Row.new(["Trip","When","Where","Meet","E-Room","Limit","Leader","Contact"],
                       [trip,swhen,where,meet,e_room,limit,leader,contact]);
  end

end
