class DepartmentController < ApplicationController

  def index
    #render :nothing => true
    redirect_back_or_default(:controller => 'department', :action => 'list')
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :rename ],
     :redirect_to => { :action => :list }
  
  def unpredictable_departments
    if not MiddleMan.jobs[:create_departments]
      MiddleMan.new_worker(
        :class => :department_creating_worker,
        :job_key => :create_departments,
        :args => 2
      )
    end
    worker = MiddleMan.worker(:create_departments)
    logger.info("\033[33m\t# Worker #{worker.jobkey} start at: #{worker.results[:do_work_time].inspect} \033[m")
    #while (Country.find(worker.id_country) == nil)
    #  worker.set_id_country(1 + random(Country.count));
    #end
    #logger.info("\033[33m Do Work \033[m")
    #logger.info("\033[33m\tid_country: #{worker.id_country} \033[m")
    #worker.create_list
    #worker.delete
    #worker.progress
#    if request.xhr?
#      render :update do |page|
#        progress_percent = MiddleMan.get_worker(session[:job_key]).progress
#        logger.info("\033[33m #{progress_percent} \033[m")
#        page.call('progressPercent', 'progressbar', progress_percent)
#        page.redirect_to(:controller => 'department', :action => 'done')   if progress_percent >= 100
#      end
#    else
      redirect_to :action => 'index'
#    end
  end
 
  def done
    flash[:notice] = _("Your Worker task has completed")
    MiddleMan.delete_worker(session[:job_key])
    render :nothing => true
    #render :inline => _("Your FooWorker task has completed")
  #render :action => "list"
  end   
  

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
   # logger.info("\033[33m department: name: #{@department.name}\033[m")
   # logger.info("\033[33m \t parent_id : #{@department.parent_id} \033[m")

    p_id = params[:parent_id].to_i > 0 ? params[:parent_id].to_i : nil
    # logger.info("\033[33m \t p_id : #{p_id} \033[m")
    @sibs = Department.find(:all, :conditions => {:parent_id => p_id}, :order => 'lft')
    #logger.info("\033[33m \t sibs: name: #{@sibs.name} \033[m")
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
