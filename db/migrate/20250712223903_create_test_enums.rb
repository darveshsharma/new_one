class CreateTestEnums < ActiveRecord::Migration[7.0]
  def change
    create_table :test_enums do |t|
      t.integer :status

      t.timestamps
    end
  end
end
