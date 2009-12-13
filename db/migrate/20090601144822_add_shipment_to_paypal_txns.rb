class AddShipmentToPaypalTxns < ActiveRecord::Migration
  def self.up
    
    add_column :paypal_txns, :name, :string
    add_column :paypal_txns, :country, :string
    add_column :paypal_txns, :city, :string
    add_column :paypal_txns, :state, :string
    add_column :paypal_txns, :zip, :string
    add_column :paypal_txns, :street, :string
    add_column :paypal_txns, :country_code, :string
  end

  def self.down
    remove_column :paypal_txns, :name, :string
    remove_column :paypal_txns, :country, :string
    remove_column :paypal_txns, :city, :string
    remove_column :paypal_txns, :state, :string
    remove_column :paypal_txns, :zip, :string
    remove_column :paypal_txns, :street, :string
    remove_column :paypal_txns, :country_code, :string
  end
end
