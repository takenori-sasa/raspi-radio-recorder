class CreateRaspioPrograms < ActiveRecord::Migration[7.0]
  def change
    create_table :raspio_programs, id: false do |t|
      t.string :id, primary_key: true
      t.references :raspio_station, type: :string, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :homepage
      t.datetime :from, null: false
      t.datetime :to, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
