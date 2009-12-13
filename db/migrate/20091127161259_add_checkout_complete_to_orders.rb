class AddCheckoutCompleteToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :checkout_complete, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :orders, :checkout_complete
  end
end