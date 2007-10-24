class DepartmentsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @departments = Departments.find(:all, :order=> "lft")#, @departments = paginate :departments, :per_page => 10
  end

  def new_department
    if params[:id] != "0"
      parent = Departments.find(params[:id])
    else
      parent = nil
    end
    departments = Departments.new
    departments.name = params[:name]
    return_data = Hash.new()
    if departments.save
      if parent != nil
        departments.move_to_child_of(parent)
      end
      return_data = {:success => true, :parent => departments.id}
    else
      return_data = {:success => false, :error => _("Department %{name} can not be created.")% {:name => params[:name] }}
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def move
    departments = Departments.find(params[:id_child])
    father = Departments.find(params[:id_father])
    return_data = Hash.new()
    if departments.move_to_child_of(father)
      return_data = {:success => true}
    else
      return_data = {:success => false, :error => _("Department ") + departments.name + _(" can not be moved.")}
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def rename
    departments = Departments.find(params[:id_node])
    departments.name = params[:new_name]
    return_data = Hash.new()
    if departments.save
      return_data = {:success => true}
    else
        return_data = {:success => false, :error => _("Department ") + params[:old_name] + _(" can not be rename to ") + params[:new_name] + "."}
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def delete
    return_data = Hash.new()
    department = Departments.find(params[:id])
    if department.destroy
      return_data = {:success => true}
    else
        return_data = {:success => false, :error => _("Department ") + params[:name] + _(" can not be deleted.")}
    end
    render :text=>return_data.to_json, :layout=>false
  end
  
  def delete_one
    return_data = Hash.new()
    department = Departments.find(params[:id])
    if department.uniq_destroy(params[:id])
      return_data = {:success => true}
    else
        return_data = {:success => false, :error => _("Department ") + params[:name] + _(" can not be deleted.")}
    end
    render :text=>return_data.to_json, :layout=>false
  end

end
