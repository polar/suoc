class ClubAnnouncement < ActiveRecord::Base
  require "stringio"
  require "faster_csv"
  
  def self.read(file)
    FasterCSV.parse(file, :headers => true) do |opts|
      t = self.new
      t.dates   = opts["Dates"]
      t.what    = opts["What"]
      t.contact = opts["Contact"]
      t.save
    end
  end

  def self.to_csv
    as = ClubAnnouncement.all
    if (as.empty?)
      FasterCSV::Table.new(
                     [FasterCSV::Row.new(["Dates","What","Contact"],
                       ["","",""])])
    else
      FasterCSV::Table.new(as.collect { |x| x.to_csv})
    end
  end

  def self.trip_table
    render :partial => "club_announcements/announcement_table",
           :locals => { :club_announcements => ClubAnnouncement.all }
  end
  
  def to_csv
    FasterCSV::Row.new(["Dates","What","Contact"],
                       [dates,what,contact]);
  end

end
