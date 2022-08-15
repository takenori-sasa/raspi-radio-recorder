class CreateRaspioRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :raspio_records do |t|

      t.timestamps
    end
  end
end
