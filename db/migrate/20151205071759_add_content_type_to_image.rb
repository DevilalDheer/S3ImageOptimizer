class AddContentTypeToImage < ActiveRecord::Migration
  def change
    add_column :aws_images, :content_type, :string
  end
end
