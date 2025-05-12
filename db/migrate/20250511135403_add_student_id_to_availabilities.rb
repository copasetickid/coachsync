class AddStudentIdToAvailabilities < ActiveRecord::Migration[8.0]
  def change
    add_column :availabilities, :student_id, :integer
    add_index :availabilities, :student_id
  end
end
