class CreateAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :availabilities do |t|
      t.integer :coach_profile_id, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, null: false, default: "available"

      t.timestamps
    end

    add_index :availabilities, :coach_profile_id
    add_index :availabilities, [ :coach_profile_id, :start_time ]
  end
end
