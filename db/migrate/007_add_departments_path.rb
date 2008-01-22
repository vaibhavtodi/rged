class AddDepartmentsPath < ActiveRecord::Migration
  def self.up
    add_column :departments, :path, :string
  end

  def self.down
    remove_column :departments, :path
  end
end