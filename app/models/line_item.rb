class LineItem < ActiveRecord::Base
	belongs_to :product
	belongs_to :cart
	belongs_to :order
	
	attr_accessible :cart_id, :product_id

	def total_price
		product.price * quantity
	end

	def change_quantity(direction, line_item_id)
		current_item = LineItem.find_by_id(line_item_id)

		if direction == 'decrement'
			if current_item.quantity > 1
				current_item.quantity -= 1
			else
				current_item.destroy
			end
		elsif direction == 'increment'
			current_item.quantity += 1
		end

		current_item
	end
end
