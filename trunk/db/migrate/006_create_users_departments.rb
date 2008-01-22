class CreateUsersDepartments < ActiveRecord::Migration
  def self.up
    create_table :users_departments do |t|
      t.integer :user_id
      t.integer :department_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users_departments
  end
end
