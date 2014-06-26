class AddQuantityToSpreeLineItemSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_line_item_subscriptions, :quantity, :integer, default: 0
  end
end
