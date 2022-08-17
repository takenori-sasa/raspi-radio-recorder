class FixReferencesInRaspioPrograms < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :raspio_programs, :raspio_stations
    add_foreign_key :raspio_programs, :raspio_stations, on_delete: :cascade
  end
end
