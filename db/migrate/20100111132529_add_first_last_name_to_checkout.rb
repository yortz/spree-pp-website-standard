class AddFirstLastNameToCheckout < ActiveRecord::Migration
  def self.up
    add_column :checkouts, :first_name, :string
    add_column :checkouts, :last_name, :string
  end

  def self.down
    remove_column :checkouts, :first_name
    remove_column :checkouts, :last_name
  end
end