class CreateCoachProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :coach_profiles do |t|
      t.integer :user_id, null: false
      t.text :bio
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :coach_profiles, :user_id, unique: true
  end
end
