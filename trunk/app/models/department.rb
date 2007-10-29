class Department < ActiveRecord::Base
  acts_as_nested_set :scope => :country_id
  belongs_to :country
end
