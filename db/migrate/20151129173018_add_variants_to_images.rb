class AddVariantsToImages < ActiveRecord::Migration
  def change
    add_column :images, :original, :boolean
    add_column :images, :zoom, :boolean
    add_column :images, :large, :boolean
    add_column :images, :small, :boolean
    add_column :images, :small_m, :boolean
  end
end
