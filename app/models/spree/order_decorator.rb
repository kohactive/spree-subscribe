Spree::Order.class_eval do

  belongs_to :subscription, :class_name => "Spree::Subscription"

  def activate_subscriptions!
    line_items.each do |line_item|
      line_item.subscriptions.start if line_item.subscriptions
    end
  end

  # DD: not unit tested
  def shipment_for_variant(variant)
    shipments.select{|s| s.include?(variant) }.first
  end

  # DD: not unit tested
  def shipping_method_for_variant(variant)
    shipment_for_variant(variant).shipping_method
  end

end

