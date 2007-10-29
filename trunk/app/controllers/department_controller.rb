class DepartmentController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :rename ],
         :redirect_to => { :action => :list }

  def list
    @department = Department.find(:all, :order=> "lft")#, @department = paginate :department, :per_page => 10
  end

  def new_department
    if params[:id] != "0"
      parent = Department.find(params[:id])
    else
      parent = nil
    end
    department = Department.new
    department.name = params[:name]
    if parent != nil
      department.country_id = parent.country_id
    else
      department.country_id = 1
    end
    return_data = Hash.new()
    if department.save
      if parent != nil
        department.move_to_child_of(parent)
      end
      return_data = {:success => true, :parent => department.id}
    else
      return_data = {:success => false, :error => _("Department %{name} can not be created.")% {:name => params[:name] }}
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def move
    department = Department.find(params[:id_child])
    father = Department.find(params[:id_father])
    return_data = Hash.new()
    if department.move_to_child_of(father)
      return_data = {:success => true}
    else
      return_data = {:success => false, :error => _("Department ") + department.name + _(" can not be moved.")}
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def rename
    department = Department.find(params[:id_node])
    return_data = Hash.new()
    if Department.update(department.id, {:name => params[:new_name]})
      return_data = {:success => true}
    else
        return_data = {:success => false, :error => _("Department ") + params[:old_name] + _(" can not be rename to ") + params[:new_name] + "."}
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def delete
    return_data = Hash.new()
    department = Department.find(params[:id])
    if department.destroy
      return_data = {:success => true}
    else
        return_data = {:success => false, :error => _("Department ") + params[:name] + _(" can not be deleted.")}
    end
    render :text=>return_data.to_json, :layout=>false
  end

  def delete_one
    return_data = Hash.new()
    department = Department.find(params[:id])
    if department.uniq_destroy(params[:id])
      return_data = {:success => true}
    else
        return_data = {:success => false, :error => _("Department ") + params[:name] + _(" can not be deleted.")}
    end
    render :text=>return_data.to_json, :layout=>false
  end

end
