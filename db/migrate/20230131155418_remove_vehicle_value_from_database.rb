class RemoveVehicleValueFromDatabase < ActiveRecord::Migration[7.0]
  def up
    change_table :vehicles, bulk: true do |t|
      t.remove :assessed_value, :included_in_assessment
    end
  end

  def down
    change_table :vehicles, bulk: true do |t|
      t.boolean :included_in_assessment, default: false, null: false
      t.decimal :assessed_value
    end
  end
end
