class CombineItemsInCart < ActiveRecord::Migration
  def up
    # replace multiple items for single product in a cart with a single item
    Cart.all.each do |cart|
      # count the number of each product in the cart
      sums = cart.line_items.group(:product_id).sum(:quantity)

      sums.each do |product_id, quantity|
	if quantity > 1
	  cart.line_items.where(product_id: product_id).delete_all

	  item = cart.line_items.build( product_id: product_id)
	  item.quantity = quantity
	  item.save!
	end
      end
    end
  end

  def down

    LineItem.where("quantity > 1").each do |lineitem|
      # add individual items
      lineitem.quantity.times do
	LineItem.create cart_id: lineitem.cart_id,
	  product_id: lineitem.product_id, quantity: 1
      end
      
      #remove original item
      lineitem.destroy
    end
  end


  def change
  end
end
