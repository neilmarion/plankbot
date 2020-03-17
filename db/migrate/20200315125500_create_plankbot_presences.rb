class CreatePlankbotPresences < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_presences do |t|
      t.integer :requestor_id, index: true
      t.datetime :from
      t.datetime :to
      t.boolean :is_online
      t.string :kind
      t.string :note

      t.timestamps
    end
  end
end
