#
# Club Office
#  This is the office of the Club.
#
class ClubOffice < ActiveRecord::Base

  has_many :officers, :foreign_key => "office_id", :class_name => "ClubOfficer", :include => "member",
          :order => "end_date ASC"

  has_many :current_officers, :foreign_key => "office_id", :class_name => "ClubOfficer", :include => "member",
           :conditions => [ "start_date <= NOW() AND NOW() <= end_date"], :order => "end_date ASC"

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

  def current_officers2
    ClubOfficer.find(:all, :conditions =>
      "office_id = '#{id}' AND start_date <= '#{Date.parse(Time.now.to_s)}' AND '#{Date.parse(Time.now.to_s)}' <= end_date")
  end

end
