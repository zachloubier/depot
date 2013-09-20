require 'test_helper'

class ProductTest < ActiveSupport::TestCase
	fixtures :products

	def new_product(image_url)
		Product.new(title: "my book title",
					description: "alsdjkf",
					price: 1,
					image_url: image_url
				   )
	end

	test "product attributes must not be empty" do
		product = Product.new
		assert product.invalid?
		assert product.errors[:title].any?
		assert product.errors[:description].any?
		assert product.errors[:price].any?
		assert product.errors[:image_url].any?
	end

	test "product price must be positive" do
		product = Product.new(title: "book title",
							  description: "asdefsdf",
							  image_url: "qwef.jpg"
							 )
		product.price = -1
		assert product.invalid?
		assert_equal "must be greater than or equal to 0.01",
			product.errors[:price].join('; ')

		product.price = 0
		assert product.invalid?
		assert_equal "must be greater than or equal to 0.01",
			product.errors[:price].join('; ')

		product.price = 1
		assert product.valid?
	end

	test "image url" do
		ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://sdf.sdfwe.dfg/w/fgh/eyrty/fred.gif }
		bad = %w{ fred.doc fred.gif/more fred.gif.more }

		ok.each do |name|
			assert new_product(name).valid?, "#{name} shouldn't be invalid"
		end

		bad.each do |name|
			assert new_product(name).invalid?, "#{name} shouldn't be valid"
		end
	end

	test "product is not valid without a unique title" do
		product = Product.new(title: products(:ruby).title,
							  description: "ajsdfpoijs",
							  price: 1,
							  image_url: "fred.gif"
							 )
		assert !product.save
		assert_equal "has already been taken", product.errors[:title].join('; ')
	end
end









