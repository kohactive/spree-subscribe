module Spree
  class SubscriptionIntervalsProducts < ActiveRecord::Base
    belongs_to :product, class_name: "Spree::Product"
    belongs_to :subscription_interval, class_name: "Spree::SubscriptionInterval"
  end
end