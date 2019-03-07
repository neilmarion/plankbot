# This migration comes from plankbot (originally 20190306021730)
class CreatePlankbotReviewerTagRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_reviewer_tag_relationships do |t|
      t.references :reviewer, index: true
      t.references :tag, index: true

      t.timestamps
    end

    add_index :plankbot_reviewer_tag_relationships, [
      :reviewer_id,
      :tag_id,
    ], unique: true, name: "rtr_reviewer_id_tag_id"
  end
end
