class Department2 < ActiveRecord::Base
  acts_as_versioned :if_changed => [:name],
    :version_column => 'version_a',
    :last_version => false,
    :super_class => self
  non_versioned_columns << 'lft' << 'rgt' << 'parent_id'

  def my_printf
    "Version class inherits of my_printf"
  end

end
