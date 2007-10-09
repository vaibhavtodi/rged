class IndexController < ApplicationController
  before_filter :login_from_cookie

  def index
     render :layout => false
  end

end
