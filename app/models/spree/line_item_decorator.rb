Spree::LineItem.class_eval do

  has_many :line_item_subscriptions
  has_many :subscriptions, through: :line_item_subscriptions

  accepts_nested_attributes_for :subscriptions

end