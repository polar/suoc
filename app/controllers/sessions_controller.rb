class SessionsController < BaseController
  def create
    user = ClubMember.find( :first,
               :conditions =>
                 ['club_memberid = ? and activated_at IS NOT NULL',
                 params[:login].delete(' -')])
    if user
      self.current_user = user.authenticated?(params[:password]) && user.update_last_login ? user : nil
    else
      self.current_user = User.authenticate(params[:login], params[:password])
    end
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end

      redirect_back_or_default(dashboard_user_path(current_user))
      flash[:notice] = :thanks_youre_now_logged_in.l
      current_user.track_activity(:logged_in)
    else
      flash[:notice] = :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again.l
      redirect_to teaser_path and return if AppConfig.closed_beta_mode
      render :action => 'new'
    end
  end
end

