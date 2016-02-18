class AddSmallMoToImage < ActiveRecord::Migration
  def change
  	add_column :aws_images, :small_mo, :boolean
  end
end
