module BaseHelper
  #
  # These are affectively aliass because the polymorphic_url function
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

end