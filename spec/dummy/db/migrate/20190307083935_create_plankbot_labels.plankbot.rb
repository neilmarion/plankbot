# This migration comes from plankbot (originally 20190306021155)
class CreatePlankbotLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_labels do |t|
      t.string :name

      t.timestamps
    end
  end
end
