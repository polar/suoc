class ClubLeader < ActiveRecord::Base
  belongs_to :member,     :class_name => "ClubMember"
  belongs_to :leadership, :class_name => "ClubLeadership"

  validates_presence_of :member
  validates_presence_of :leadership

  validates_date :start_date, :before => Proc.new { Date.today }
  validates_date :end_date, :after => :start_date

  def current?
    start_date <= Date.today && Date.today <= end_date
  end

  def validate_on_create
    # apparently validates_presence_of doesn't call back before this!

    if leadership && leadership.leader?(member)
      errors.add_to_base("#{member.login} is already a leader in #{leadership.name}. Perhaps s/he is not Active/Life?")
    end
  end

end
