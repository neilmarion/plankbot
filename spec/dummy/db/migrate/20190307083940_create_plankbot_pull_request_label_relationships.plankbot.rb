# This migration comes from plankbot (originally 20190307002124)
class CreatePlankbotPullRequestLabelRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :plankbot_pull_request_label_relationships do |t|
      t.references :pull_request, index: {name: 'index_plankbot_label_on_pr_id'}
      t.references :label, index: {name: 'index_plankbot_pr_on_label_id'}

      t.timestamps
    end

    add_index :plankbot_pull_request_label_relationships, [
      :pull_request_id,
      :label_id,
    ], unique: true, name: "prlr_pr_id_label_id"
  end
end
