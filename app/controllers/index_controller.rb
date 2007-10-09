class IndexController < ApplicationController
  before_filter :login_required

  def index
    render :layout => false
  end

end
