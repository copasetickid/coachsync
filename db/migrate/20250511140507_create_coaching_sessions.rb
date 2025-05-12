class CreateCoachingSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :coaching_sessions do |t|
      t.integer :coach_profile_id
      t.integer :student_id
      t.integer :availability_id
      t.string :status
      t.integer :satisfaction_score
      t.text :notes

      t.timestamps
    end

    add_index :coaching_sessions, :coach_profile_id
    add_index :coaching_sessions, :student_id
    add_index :coaching_sessions, :availability_id
    add_index :coaching_sessions, :status
  end
end
