module BaseHelper
  #
  # These are affectively aliases because the polymorphic_url function
  # derives "club_member" from a user with the ClubMember extension.
  #
  def club_member_post_url(a,b,args={});user_post_url(a,b,args);end
  def club_member_friendship_url(a,b,args={}); user_friendship_url(a,b,args);end
  def club_member_photo_url(a,b,args={}); user_photo_url(a,b,args);end
  def club_member_activity_url(a,b,args={}); user_activity_url(a,b,args);end
  def club_member_nessage_url(a,b,args={}); user_message_url(a,b,args);end
  def club_member_clipping_url(a,b,args={}); user_clipping_url(a,b,args);end
  def club_member_invitation_url(a,b,args={}); user_invitation_url(a,b,args);end
  def club_member_offering_url(a,b,args={}); user_offering_url(a,b,args);end
  def club_member_favorite_url(a,b,args={}); user_favorite_url(a,b,args);end
  def club_member_comment_url(a,b,args={}); user_comment_url(a,b,args);end

  #
  # This function gets called if the filter functions deny access.
  #
  def permission_denied
    render :inline => "<h3>Permission Denied</h3><p>You are not allowed to access this section.",
           :status => :forbidden
  end
end