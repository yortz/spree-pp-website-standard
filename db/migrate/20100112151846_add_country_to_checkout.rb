class AddCountryToCheckout < ActiveRecord::Migration
  def self.up
    add_column :checkouts, :country, :string
  end

  def self.down
    remove_column :checkouts, :country
  end
end