class CreateImages < ActiveRecord::Migration
  def change
    create_table :aws_images do |t|
      t.string :path, null: false
      t.string :original_size
      t.string :current_size
      t.boolean :optimized, null: false, default: false
      t.boolean :modified, null: false, default: false
      t.references :dir_path, index: true, null: false

      t.timestamps null: false
      t.index :path, unique: true
    end
    add_foreign_key :aws_images, :dir_paths
  end
end
