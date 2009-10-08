module UsersHelper

  #
  # This renders the avatar with a link to
  # create on if the user doesn't have one.
  #
  def render_avatar(suocer, current)
    render :partial => "profile_picture", :locals => {
      :suocer => suocer, :current => current }
  end

  #
  # This function renders the badge with an optional
  # link for the avatar.
  #
  def render_badge(member, link = nil)
    render :partial => "user_badge", :locals => {
      :member => member, :link => link }
  end

  #
  # Optionally renders the "About Me" description
  #
  def render_description(member, current)
    if (suocer.user.description)
      render :partial => "user_description", :locals => {
             :member => member, :current => current }
    end
  end

  #
  # This function renders a list of Current ClubLeaderships.
  #
  def render_leaderships(leaders)
    if !leaders.empty?
      render :partial => "member_leaders", 
             :locals => { :member_leaders => leaders }
   end
  end

  #
  # This function renders a list of Current ClubcOfficers.
  #
  def render_offices(officers)
    if !officers.empty?
      render :partial => "member_officers",
             :locals => { :member_officers => officers }
   end
  end

  include ClubMembershipsHelper
  #
  # This function renders the table of Membershps for a particular member
  #
  def render_memberships(member)
    memberships = member.memberships
    if !memberships.empty?
      render :partial => "member_memberships",
             :locals => { :member_memberships => memberships }
    end
  end
  
  def render_membership_slacker(member)
    if member.is_slacker?
      render :partial => "member_slacker"
   end
  end

  #
  # This function renders a list of ClubChairmanships
  #
  def render_chairmanships(chairs)
    if !chairs.empty?
      render :partial => "member_chairs",
             :locals => { :member_chairs => chairs }
   end
  end

  def render_certifications(certs)
    if !certs.empty?
      render :partial => "member_certs", 
             :locals => { :member_certs => certs }
    end
  end

  #
  # This function renders the information of a particular
  # ClubMember. The boolean showedit is if we should render
  # a link to edit.
  #
  def render_club_member_info( member, showedit, clazz = nil )
    render :partial => "club_member_info", :locals => {
      :member => member,
      :showedit => showedit,
      :clazz => clazz
      }
  end

  #
  # This function renders the information of a particular
  # ClubMember with links to edit.
  #
  def render_edit_club_member_info( member, clazz = nil )
    render :partial => "edit_club_member_info", :locals => {
      :member => member,
      :clazz => clazz
      }
  end

  def render_club_profile_info( member )
    render :partial => "club_profile_info", :locals => {
      :member => member,
      :showedit => permitted_to?(:write, member)
      }
  end

  # TODO: Split up submitted trips into a scroll box.
  def render_trip_registrations( member )
    trip_regs = ClubTripRegistration.all(
                    :conditions => { :leader_id => member, :submit_date => nil },
                    :order => "departure_date DESC")
    render :partial => "club_trip_registrations", :locals => {
      :member => member,
      :trip_regs => trip_regs
    }
  end


  def render_current_certs( member )
    certs = CertMemberCert.current(member)
    render :partial => "cert_collection", :locals => {
        :certs => certs }
  end

  def show_tr_edit(trip_reg)
    !trip_reg.submitted? && trip_reg.leader == current_user
  end

  def show_tr_delete(trip_reg)
    !trip_reg.submitted? && trip_reg.leader == current_user
  end

  def show_cert_verify(user, cert)
    !cert.verified? && permitted_to?(:verify_cert, user) && permitted_to?(:verify, cert)
  end

  def show_cert_delete(user,cert)
     permitted_to?(:delete_cert, user) && permitted_to?(:delete, cert)
  end

  def show_leader_verify(user, leader)
    !leader.verified? && permitted_to?(:verify_leader, user) && permitted_to?(:verify, leader)
  end

  def show_leader_delete(user, leader)
     permitted_to?(:delete_leader, user) && permitted_to?(:delete, leader)
  end

  def fmt_memberid(member)
    if member.club_memberid && member.club_memberid.length > 5
      member.club_memberid.insert(5,"-")
    end
  end
end
