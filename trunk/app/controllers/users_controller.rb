class UsersController < ApplicationController
  include UIEnhancements::SubList
  helper :SubList
  
  sub_list 'Users_department', 'user' do |new_department|
 #Place any construction (ie. defaults) required here
    new_department.department_id = 1
  end
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update],
         :redirect_to => { :action => :list }

  def list
    @users = User.find :all
  end
  
  def list_department
    @user = session[:user]#User.find(params[:id] || session[:user][:id])
    department = @user.users_departments
    return_data = []
    department.each do |dp|
        return_data.push({:name => dp.department.name, :id => dp.department.id})
        dp.department.all_children().each { |i|  
          return_data.push({:name => ('-' * i.level) + i.name, :id => i.id})
        }
    end
    render :text => {:total => return_data.length, :rows => return_data}.to_json, :layout => false 
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:User])
    success = true
    success &&= initialize_users_departments
    success &&= @user.save
    if success
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      prepare_users_departments
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    success = true
    success &&= initialize_users_departments(@user)
    success &&= @user.update_attributes(params[:User])
    if success
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      prepare_users_departments
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
