module ClubMembershipsHelper
  def render_membership_row(membership, usename = true)
    render :partial => "club_memberships/membership_row", :locals => {
      :membership => membership,
      :usename => usename
    }
  end
  
  def fmt_memberid(member)
    if member.club_memberid && member.club_memberid.length > 5
      member.club_memberid.insert(5,"-")
    end
  end
  
end
