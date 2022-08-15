class CreateRaspioTimeTables < ActiveRecord::Migration[7.0]
  def change
    create_table :raspio_time_tables do |t|
      t.references :station, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :homepage
      t.time :from, null: false
      t.time :to, null: false

      t.timestamps
    end
  end
end
