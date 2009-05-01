class ClubLoginMessage < ActiveRecord::Base
  belongs_to :author, :class_name => "ClubMember"

  validates_date :date
  validates_presence_of :author
end
