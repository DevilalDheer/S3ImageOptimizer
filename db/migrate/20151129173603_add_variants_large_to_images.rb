class AddVariantsLargeToImages < ActiveRecord::Migration
  def change
    add_column :aws_images, :large_m, :boolean
  end
end
