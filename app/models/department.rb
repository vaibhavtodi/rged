class Department < ActiveRecord::Base
  acts_as_versioned :if_changed => [:county_id, :name], 
    :version_column => 'version_a',
    :super_class => self
  non_versioned_columns << 'lft' << 'rgt' << 'parent_id'
  acts_as_nested_set :scope => :country_id
  belongs_to :country
  has_many :users_departments, :dependent => :destroy
  has_many :users, :through => :users_departments
  def toto
    "toto"
  end
end
