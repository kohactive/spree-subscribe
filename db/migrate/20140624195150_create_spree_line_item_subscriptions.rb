class CreateSpreeLineItemSubscriptions < ActiveRecord::Migration
  def change
    create_table :spree_line_item_subscriptions do |t|
      t.references :subscription, index: true
      t.references :line_item, index: true
    end
  end
end
