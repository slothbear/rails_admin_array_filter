class CreateBugs < ActiveRecord::Migration
  def change
    create_table :bugs do |t|
      t.string :description
      t.text :tags, array: true, default: []

      t.timestamps null: false
    end
  end
end
