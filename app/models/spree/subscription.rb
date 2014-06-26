require 'concerns/intervalable'

module Spree
  class Subscription < ActiveRecord::Base

    include Intervalable

    attr_accessor :new_order

    has_many :line_item_subscriptions
    has_many :line_items, through: :line_item_subscriptions

    belongs_to :billing_address, :foreign_key => :billing_address_id, :class_name => "Spree::Address"
    belongs_to :shipping_address, :foreign_key => :shipping_address_id, :class_name => "Spree::Address"
    belongs_to :shipping_method
    #belongs_to :interval, :class_name => "Spree::SubscriptionInterval"
    belongs_to :source, :polymorphic => true, :validate => true
    belongs_to :payment_method
    belongs_to :user, :class_name => Spree.user_class.to_s

    has_many :reorders, :class_name => "Spree::Order"

    scope :active, where(:state => 'active')

    state_machine :state, :initial => 'cart' do
      event :suspend do
        transition :to => 'inactive', :from => 'active'
      end
      event :start, :resume do
        transition :to => 'active', :from => ['cart','inactive']
      end
      event :cancel do
        transition :to => 'cancelled', :from => 'active'
      end

      after_transition :on => :start, :do => :set_checkout_requirements
      after_transition :on => :resume, :do => :check_reorder_date
    end

    # DD: TODO pull out into a ReorderBuilding someday
    def reorder
      raise false unless self.state == 'active'

      create_reorder &&
      add_subscribed_line_items &&
      select_shipping &&
      add_payment &&
      confirm_reorder &&
      complete_reorder &&
      calculate_reorder_date!
    end

    def create_reorder
      puts "create reorder..."
      self.new_order = Spree::Order.create(
          bill_address: self.billing_address,
          ship_address: self.shipping_address,
          subscription_id: self.id,
          email: self.user.email,
          subscription_reorder: true
        )
      self.new_order.user_id = self.user_id
      return self.new_order
    end

    def add_subscribed_line_items
      puts "add_subscribed_line_items..."
      line_items.each do |line_item|      
        variant = Spree::Variant.find(line_item.variant_id)
        quantity = line_item_subscriptions.where(line_item: line_item).first.quantity rescue 0
        line_item = self.new_order.contents.add( variant, quantity)
        line_item.price = line_item.price
        line_item.save!
      end

      puts "self.new_order.shipments:: #{self.new_order.shipments.inspect}"

      self.new_order.next
      self.new_order.next
    end

    def select_shipping
      puts "select_shipping:: #{self.new_order.state}"
      # DD: shipments are created when order state goes to "delivery"
      shipment = self.new_order.shipments.first # DD: there should be only one shipment
      rate = shipment.shipping_rates.first{|r| r.shipping_method.id == self.shipping_method.id }
      raise "No rate was found. TODO: Implement logic to select the cheapest rate." unless rate
      shipment.selected_shipping_rate_id = rate.id
      shipment.save
    end

    def add_payment
      puts "add_payment..."
      payment = self.new_order.payments.build( :amount => self.new_order.item_total )
      payment.source = self.source
      payment.payment_method = self.payment_method
      payment.save!

      self.new_order.next # -> payment
    end

    def confirm_reorder
      puts "confirm_reorder"
      self.new_order.next # -> confirm
    end

    def complete_reorder
      puts "complete_reorder"
      self.new_order.update!
      self.new_order.next && self.new_order.save # -> complete
    end

    def calculate_reorder_date!
      puts "calculate_reorder_date"
      self.reorder_on ||= Date.today
      self.reorder_on += self.time
      save
    end

    def products
      line_items.collect { |l| l.product.series_name }.join(", ")
    end

    def display_total
      reorders.last.display_total
    end

    private

    # DD: if resuming an old subscription
    def check_reorder_date
      if reorder_on <= Date.today
        reorder_on = Date.tomorrow
        save
      end
    end

    # DD: assumes interval attributes come in when created/updated in cart
    def set_checkout_requirements
      order = self.line_items.first.order
      # DD: TODO: set quantity?
      calculate_reorder_date!
      update_attributes(
        :billing_address_id => order.bill_address_id,
        :shipping_address_id => order.ship_address_id,
        :shipping_method_id => order.shipping_method_for_variant( self.line_items.first.variant ).id,
        :payment_method_id => order.payments.first.payment_method_id,
        :source_id => order.payments.first.source_id,
        :source_type => order.payments.first.source_type,
        :user_id => order.user_id
      )
    end

    def self.reorder_states
      @reorder_states ||= state_machine.states.map(&:name) - ["cart"]
    end

    # Start an array of subscriptions at once
    def self.start
      scoped.each { |s| s.start }
    end

  end
end