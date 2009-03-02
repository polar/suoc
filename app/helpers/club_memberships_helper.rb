module ClubMembershipsHelper
  def render_membership_row(membership, usename = true)
    render :partial => "club_memberships/membership_row", :locals => {
      :membership => membership,
      :usename => usename
    }
  end
end
