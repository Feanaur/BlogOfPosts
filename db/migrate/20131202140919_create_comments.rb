class CreateComments < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.string :body
      t.belongs_to :user, :post
      t.timestamps
    end
  end

  def down
    drop_table :comments
  end
end
