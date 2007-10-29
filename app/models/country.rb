class Country < ActiveRecord::Base
has_many :departments, :dependent => :destroy
end
