Spree::Product.class_eval do

  delegate_belongs_to :master, :subscribed_price

  has_many :subscription_intervals_products, dependent: :destroy, class_name: "Spree::SubscriptionIntervalsProducts"
  has_many :subscription_intervals, through: :subscription_intervals_products, class_name: "Spree::SubscriptionInterval"
  alias :intervals :subscription_intervals
  
  scope :subscribable, -> { where(:subscribable => true) }
  scope :unsubscribable, -> { where(:subscribable => false) }

end
