class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  def default
    session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end

  # say something nice, you goof!  something sweet.
  #  def index
  #    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  #  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        #if self.current_user != nil
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
          
       # else
       #   redirect_back_or_default(:controller => 'account', :action => 'login')
       #   flash[:notice] = _("Logged in failed")
       # end
      end
      session[:user] = User.find_by_id(self.current_user)
      redirect_back_or_default(:controller => 'index', :action => 'index')
      flash[:notice] = _("Logged in successfully")
    else
      flash[:notice] = _("Logged in failed")
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    if @user.save!
      self.current_user = @user
      redirect_back_or_default(:controller => 'index', :action => 'index')
      flash[:notice] = _("Thanks for signing up!")
    else
      flash[:notice] = @user.errors.full_messages.join("<br />")
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  def logout
    self.current_user = nil
    cookies.delete :auth_token
    reset_session
    flash[:notice] = _("You have been logged out.")
    redirect_back_or_default(:controller => '/account', :action => 'login')
  end
end
