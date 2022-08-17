class FixUniquenessInRaspioPrograms < ActiveRecord::Migration[7.0]
  def change
    remove_index :raspio_programs, column: [:raspio_station_id, :from, :to]
    add_index :raspio_programs, [:from, :raspio_station_id, :to], unique: true
  end
end
