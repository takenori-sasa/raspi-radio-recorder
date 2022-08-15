class CreateRaspioStations < ActiveRecord::Migration[7.0]
  def change
    create_table :raspio_stations, id: false do |t|
      t.string :id, primary_key: true
      t.string :name, null: false
      t.string :banner
      t.boolean :timeshift, default: false

      t.timestamps
    end
  end
end
