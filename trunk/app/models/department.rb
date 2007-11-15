class Department < ActiveRecord::Base
  acts_as_versioned :if_changed => [:county_id, :name], 
    :version_column => 'version_a',
    :last_version => 1    
  non_versioned_columns << 'lft' << 'rgt' << 'parent_id'
  acts_as_nested_set :scope => :country_id
  belongs_to :country
end
