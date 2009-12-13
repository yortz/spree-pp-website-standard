class AddTaxAmountToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :tax_amount, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :orders, :tax_amount
  end
end