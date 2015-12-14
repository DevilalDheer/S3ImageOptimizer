class AddVariantsToImages < ActiveRecord::Migration
  def change
    add_column :aws_images, :original, :boolean
    add_column :aws_images, :zoom, :boolean
    add_column :aws_images, :large, :boolean
    add_column :aws_images, :small, :boolean
    add_column :aws_images, :small_m, :boolean
  end
end
