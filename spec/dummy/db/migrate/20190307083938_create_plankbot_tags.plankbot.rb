# This migration comes from plankbot (originally 20190306021651)
class CreatePlankbotTags < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_tags do |t|
      t.string :name
      t.string :kind
      t.string :description

      t.timestamps
    end
  end
end
