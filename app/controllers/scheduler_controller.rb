class SchedulerController < ApplicationController
  def index
    #render :nothing => true
    redirect_back_or_default(:controller => 'scheduler', :action => 'list')
  end
  
  def list
    
  end
  
end
