require 'concerns/intervalable'

module Spree
  class SubscriptionInterval < ActiveRecord::Base

    include Intervalable
    
    has_many :subscription_intervals_products, dependent: :destroy, class_name: "Spree::SubscriptionIntervalsProducts"
    has_many :products, through: :subscription_intervals_products, class_name: "Spree::SubscriptionInterval"

  end
end