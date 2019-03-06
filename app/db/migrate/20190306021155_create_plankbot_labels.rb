class CreatePlankbotLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_labels do |t|
      t.string :name
      t.integer :reviewer_count

      t.timestamps
    end
  end
end
