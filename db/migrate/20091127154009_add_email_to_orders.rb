class AddEmailToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :email, :string
  end

  def self.down
    remove_colum :orders, :email
  end
end