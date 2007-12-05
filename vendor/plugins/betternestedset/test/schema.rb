ActiveRecord::Schema.define :version => 0 do
  create_table :mixins, :force => true do |t|
    t.column :parent_id,    :integer
    t.column :pos,          :integer
    t.column :created_at,   :datetime
    t.column :updated_at,   :datetime
    t.column :lft,          :integer
    t.column :rgt,          :integer
    t.column :root_id,      :integer
    t.column :type,         :string
  end

  create_table :countries, :force => true do |t|
    t.column :name, :string
  end

  create_table "departments", :force => true do |t|
    t.integer "parent_id"
    t.integer "country_id"
    t.integer "lft"
    t.integer "rgt"
    t.string  "name"
  end

end
