class AddVersions < ActiveRecord::Migration
  def self.up
    create_table :department_versions do |t|
      t.column :department_id, :integer
      t.column :country_id, :integer
      t.column :version_a, :integer
      t.column :name, :string
    end
  end

  def self.down
    drop_table :department_versions
  end
end
