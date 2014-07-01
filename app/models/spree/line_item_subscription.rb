module Spree
	class LineItemSubscription < ActiveRecord::Base
	  
	  belongs_to :subscription, dependent: :destroy
	  belongs_to :line_item

	end
end