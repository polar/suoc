class ClubTripRegistrationsConfiguration < ActiveRecord::Base
  validates_format_of :notification_email, :with => /\A\s*([a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)(,\s*[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)*\s*\Z/
end
