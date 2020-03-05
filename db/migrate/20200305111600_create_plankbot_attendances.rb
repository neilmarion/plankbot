class CreatePlankbotAttendances < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_attendances do |t|
      t.integer :requestor_id, index: true
      t.date :date
      t.string :kind
      t.string :note

      t.timestamps
    end
  end
end
