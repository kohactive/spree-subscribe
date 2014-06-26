class RemoveLineItemIdFromSubscriptions < ActiveRecord::Migration
  def change
  	remove_column :spree_subscriptions, :line_item_id
  end
end
