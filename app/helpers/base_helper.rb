module BaseHelper

  def commentable_url(comment)
    if comment.commentable_type != "User" && comment.commentable_type != "ClubMember"
      polymorphic_url([comment.recipient, comment.commentable])+"#comment_#{comment.id}"
    else
      user_url(comment.recipient)+"#comment_#{comment.id}"
    end
  end

end