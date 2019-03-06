class CreatePlankbotReviewerTagRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_reviewer_tag_relationships do |t|
      t.references :reviewer, index: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
