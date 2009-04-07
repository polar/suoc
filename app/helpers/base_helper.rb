module BaseHelper
  #
  # These are affectively aliass because the polymorphic_url function
  # derives "club_member" from a user with the ClubMember extension.
  #
  def club_member_post_url(a,b,args={});user_post_url(a,b,args);end
  def club_member_friendship_(a,b,args={}); user_friendship_(a,b,args);end
  def club_member_photo_(a,b,args={}); user_photo_(a,b,args);end
  def club_member_activity_(a,b,args={}); user_activity_(a,b,args);end
  def club_member_nessage_(a,b,args={}); user_message_(a,b,args);end
  def club_member_clipping_(a,b,args={}); user_clipping_(a,b,args);end
  def club_member_invitation_(a,b,args={}); user_invitation_(a,b,args);end
  def club_member_offering_(a,b,args={}); user_offering_(a,b,args);end
  def club_member_favorite_(a,b,args={}); user_favorite_(a,b,args);end
  def club_member_comment_(a,b,args={}); user_comment_(a,b,args);end

end