# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  include AuthenticatedSystem

  session :session_key => '_rged_session_id'
end
