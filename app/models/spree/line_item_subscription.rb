module Spree
	class LineItemSubscription < ActiveRecord::Base
	  
	  belongs_to :subscription
	  belongs_to :line_item

	end
end