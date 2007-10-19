module DepartmentsHelper
  def get_indentation(department, n=0)
    $n = n
    if department.send(department.parent_column) == nil
      return $n
    else
      parent = Departments.find(department.send(department.parent_column))
      get_indentation(parent, $n += 1)
    end
  end
  
  
end
