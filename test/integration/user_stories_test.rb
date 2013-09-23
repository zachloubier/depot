require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products

  test "buying a product" do
  	# Delete all line items and orders and set the product to the fixture product "ruby"
	  LineItem.delete_all
	  Order.delete_all
	  ruby_book = products(:ruby)

	  # User goes to index page
	  get "/"
	  assert_response :success
	  assert_template "index"

	  # User adds the ruby_book to their cart via ajax
	  xml_http_request :post, '/line_items', product_id: ruby_book.id
	  assert_response :success

	  # Ensure the book was added to the cart and exactly one of them exists
	  cart = Cart.find(session[:cart_id])
	  assert_equal 1, cart.line_items.size
	  assert_equal ruby_book, cart.line_items[0].product

	  # Create a new order
	  get "/orders/new"
	  assert_response :success
	  assert_template "new"

	  # User submits data to order field, cart is now empty/deleted
	  post_via_redirect "/orders", order: {
	  	name: "Dave Thomas",
	  	address: "123 The Street",
	  	email: "dave@example.com",
	  	pay_type: "Check"
	  }
	  assert_response :success
	  assert_template "index"
	  cart = Cart.find(session[:cart_id])
	  assert_equal 0, cart.line_items.size

	  # Ensure the order and corresponding line item was created
	  orders = Order.all
	  assert_equal 1, orders.size
	  order = orders[0]
 
	  assert_equal "Dave Thomas", order.name
	  assert_equal "123 The Street", order.address
	  assert_equal "dave@example.com", order.email
	  assert_equal "Check", order.pay_type

	  assert_equal 1, order.line_items.size
	  line_item = order.line_items[0]
	  assert_equal ruby_book, line_item.product

	  # Verify the mail is correctly addressed and has the right subject line
	  mail = ActionMailer::Base.deliveries.last
	  assert_equal ["dave@example.com"], mail.to
	  assert_equal 'Zach Loubier <from@example.com>', mail[:from].value
	  assert_equal "Pragmatic Store Order Confirmation", mail.subject
	end
end










