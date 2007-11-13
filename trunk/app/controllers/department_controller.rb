class DepartmentController < ApplicationController
  
  def index
    redirect_back_or_default(:controller => 'department', :action => 'list')
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :rename ],
     :redirect_to => { :action => :list }

  def list
    if request.xhr? && params[:node] # json_node
      p_id = params[:node].to_i > 0 ? params[:node] : nil
      roots = Department.find(:all, :conditions => {:parent_id => p_id}, :order => 'lft').collect{ |r|
       {'id' => r.id, 'text' => r.name, 'leaf' => (r.all_children_count == 0) }
      }
      render :json => roots.to_json
    end
  end

  def create
    if !(params[:parent].equal?("0"))
      parent = Department.find_by_name(params[:parent])
    else
      parent = nil
    end
    department = Department.new
    department.name = params[:name]
    department.country_id = Country.find_by_name(params[:country]).id
     if department.save
      if parent != nil
        department.move_to_child_of(parent)
      end
      redirect_back_or_default(:controller => 'department', :action => 'list')
      flash[:notice] = _("Department Created")
    else
      redirect_back_or_default(:controller => 'department', :action => 'list')
      flash[:notice] = _("Create Failed")
    end
  end

  def move
    @department = Department.find(params[:id])
    p_id = params[:parent_id].to_i > 0 ? params[:parent_id].to_i : nil
    @sibs = Department.find(:all, :conditions => {:parent_id => p_id}, :order => 'lft')
    if @sibs.any?
      dest = @sibs[params[:index].to_i] || @sibs.clear
    end

    resp = {}
    if (@sibs.empty? ? @department.move_to_child_of(p_id) :@department.move_to_left_of(dest))
      resp[:success] = true
    else
      resp[:success] = false
      resp[:error] = _("%{model} %{name} can not be moved.")% {:model => _("Department"), :name => @department.disp_name}
    end
    render :json => resp.to_json, :layout => false
  end

  def find_by_version(version)
    int=0;
    version.split('.').reverse.each_with_index {|i,idx| int+=(i.to_i << ((idx)*8))}
    find_by_version_int(int)
  end

  def update
    department = Department.find(params[:id])
    department.name = params[:name]
    department.country_id = Country.find_by_name(params[:country]).id
    version = params[:version]
    version = version.to_i  
    if department.version_a != version
      if department.revert_to!(version)
        redirect_back_or_default(:controller => 'department', :action => 'list')
        flash[:notice] = _("Department Updated")
      else
        redirect_back_or_default(:controller => 'department', :action => 'list')
        flash[:notice] = _("Update failed")
      end
    else
      if department.save #&& department.reset_version(version + 1)
        redirect_back_or_default(:controller => 'department', :action => 'list')
        flash[:notice] = _("Department Updated")
      else
        redirect_back_or_default(:controller => 'department', :action => 'list')
        flash[:notice] = _("Update failed")
      end
    end
  end

  def destroy
    return_data = Hash.new()
    department = Department.find(params[:id])
    if params[:only_one] == "1"
      if department.uniq_destroy(params[:id])
        return_data = {:success => true}
      else
        return_data = {:success => false, :error => _("Department ") + params[:name] + _(" can not be deleted.")}
      end
    else
      if department.destroy
        return_data = {:success => true}
      else
        return_data = {:success => false, :error => _("Department ") + params[:name] + _(" can not be deleted.")}
      end
    end
    render :json=>return_data.to_json, :layout=>false
  end
  
  def show
    @node = Department.find(params[:id])
  end

  def edit
    @node = Department.find(params[:id])
  end
  
  def new
    @parent_id = params[:parent_id]
  end
end
