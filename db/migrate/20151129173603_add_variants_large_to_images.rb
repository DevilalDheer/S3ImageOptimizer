class AddVariantsLargeToImages < ActiveRecord::Migration
  def change
    add_column :images, :large_m, :boolean
  end
end
