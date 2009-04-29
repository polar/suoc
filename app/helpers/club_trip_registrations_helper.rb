module ClubTripRegistrationsHelper
  def show_edit?(trip_reg)
    !trip_reg.submitted? && trip_reg.leader == current_user
  end
end