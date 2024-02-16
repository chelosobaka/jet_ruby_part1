require_relative 'lib/order'

begin
  order = Order.new
  order.geocoder_api_key = 'OtNMK79oXZlSUzqektjEKbrX4Hag12mBvd4PD6SAzkx0VAReUk8R7Vswpu65Rhe0'
  order.distancematrix_api_key = 'Qg7IeKNjC7mNyL6pJAUatbB3IvRZkZqCrNyfS2KHHsXI1WDEQ8cGWp6aN1F8Wye1'

  puts 'Enter weight (kg)'
  order.weight = gets.chomp.to_f

  puts 'Enter length (cm)'
  order.length = gets.chomp.to_f

  puts 'Enter width (cm)'
  order.width = gets.chomp.to_f

  puts 'Enter height (cm)'
  order.height = gets.chomp.to_f

  puts 'Enter origins'
  order.origins = gets.chomp

  puts 'Enter destinations'
  order.destinations = gets.chomp

  puts order.calc_order
rescue StandardError => e
  puts "Fails: #{e}"
end
