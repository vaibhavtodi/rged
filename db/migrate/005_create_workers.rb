class CreateWorkers < ActiveRecord::Migration
  def self.up
    create_table :workers do |t|
      t.column :name, :string
      t.column :sec, :integer
      t.column :min, :integer
      t.column :hour, :integer
      t.column :day, :integer
      t.column :month, :integer
      t.column :weekday, :integer
      t.column :year, :integer
    end
  end

  def self.down
    drop_table :workers
  end
end
