class AddAssignmentToBug < ActiveRecord::Migration
  def change
    add_column :bugs, :assignment, :string
  end
end
