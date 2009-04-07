#
# Club Office
#  This is the office of the Club.
#
class ClubOffice < ActiveRecord::Base

  acts_as_list
  
  validates_presence_of :name

  validates_uniqueness_of :name

  def past_officers(page, per_page)
    ClubOfficer.paginate(:all,
      :page => page,
      :per_page => per_page,
      :order => 'end_date DESC',
      :conditions => 
        "office_id = '#{id}' AND end_date < '#{Date.parse(Time.now.to_s)}'")
  end
  
  def current_officers
    ClubOfficer.find(:all, :conditions => 
      "office_id = '#{id}' AND start_date <= '#{Date.parse(Time.now.to_s)}' AND '#{Date.parse(Time.now.to_s)}' <= end_date")
  end
  
end
