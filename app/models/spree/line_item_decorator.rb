Spree::LineItem.class_eval do

  has_many :line_item_subscriptions
  has_many :subscriptions, through: :line_item_subscriptions

  accepts_nested_attributes_for :subscriptions

  def subscription
  	subscriptions.first rescue nil
  end

  def multiple_subscriptions?
  	subscriptions.count > 1
  end

end