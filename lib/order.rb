require 'net/http'
require 'json'

# Class for calculate order
class Order
  attr_accessor :distancematrix_api_key, :geocoder_api_key, :weight, :length,
                :width, :height

  attr_reader :origins, :destinations

  def origins=(origins)
    @origins = coordinates?(origins) ? origins.split(/,\s*/).map(&:to_f) : get_coordinates(origins)
  end

  def destinations=(destinations)
    @destinations = coordinates?(destinations) ? destinations.split(/,\s*/).map(&:to_f) : get_coordinates(destinations)
  end

  def calc_order
    distance = calc_distance
    price = calc_price(distance).round(2, half: :up)

    { weight: weight, length: length, width: width, height: height, distance: distance, price: price }
  rescue StandardError
    {}
  end

  private

  # return value in meters
  def calc_distance
    path = 'https://api-v2.distancematrix.ai/maps/api/distancematrix/json?' \
           "origins=#{origins.join(',')}&" \
           "destinations=#{destinations.join(',')}&key=#{distancematrix_api_key}"
    url = URI.parse(URI::Parser.new.escape(path))
    response = JSON.parse(Net::HTTP.get(url))
    distance = response.dig('rows', 0, 'elements', 0, 'distance', 'value')
    distance.positive? ? distance : raise(StandardError)
  rescue StandardError => e
    raise StandardError, "calc_distance: #{e}"
  end

  def calc_price(distance)
    if volume <= 1
      distance / 1000.0
    elsif weight <= 10
      2 * distance / 1000.0
    else
      3 * distance / 1000.0
    end
  rescue StandardError => e
    raise StandardError, "calc_price: #{e}"
  end

  # return value in meters
  def volume
    (width.to_f * length.to_f * height.to_f) / 1_000_000.0
  rescue StandardError => e
    raise StandardError, "volume: #{e}"
  end

  def coordinates?(value)
    /^[-+]?\d+\.\d+,\s*[-+]?\d+\.\d+$/.match?(value)
  end

  def get_coordinates(address)
    address.strip!
    address = address.gsub(/\s+/, '+') || address
    path = "https://api-v2.distancematrix.ai/maps/api/geocode/json?address=#{address}&key=#{geocoder_api_key}"
    url = URI.parse(URI::Parser.new.escape(path))
    response = JSON.parse(Net::HTTP.get(url))
    location = response.dig('result', 0, 'geometry', 'location') || raise(StandardError)

    [location['lat'].to_f, location['lng'].to_f]
  rescue StandardError
    raise StandardError, "Couldn't get coordinates"
  end
end
