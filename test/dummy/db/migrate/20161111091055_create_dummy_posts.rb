class CreateDummyPosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.string :summary
      t.text :article
      t.references :owner, index: true

      t.timestamps null: false
    end
  end
end
