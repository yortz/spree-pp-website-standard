class AddIpAddressToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :ip_address, :string
  end

  def self.down
    remove_colum :orders, :ip_address
  end
end