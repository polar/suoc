#
# Club Office
#  This is the office of which an undergraduate holds.
#
class ClubOffice < ActiveRecord::Base

  validates_presence_of :name

  validates_uniqueness_of :name

  def current_officers
    ClubOfficer.find(:all, :conditions => 
      "office_id = '#{id}' AND start_date <= '#{Date.parse(Time.now.to_s)}' AND '#{Date.parse(Time.now.to_s)}' < end_date")
  end
  
end
