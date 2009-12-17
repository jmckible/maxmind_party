require 'rubygems'
require 'httparty'
require 'open-uri'

module MaxMind
  
  class GeoIP
    include HTTParty
    format :plain
    headers 'Content-Type'=>'application/x-www-form-urlencoded'

    def self.authorize(api_key, uri='geoip3.maxmind.com')
      GeoIP.default_params :l=>api_key
      GeoIP.base_uri uri
    end

    def self.lookup(ip)
      raise 'Please authorize with your API key' unless default_options[:base_uri]
      Location.new ip, GeoIP.get('/b', :query=>{:i=>ip})
    end
  end
  
  class Location
    # Expects comma delimited string from MaxMind
    # Country, Region, City, Lat, Long, Error Code, Area Code, IP Owner, ISP
    # eg - US,NY,Jamaica,,40.686001,-73.792099,501,718,"Road Runner","Road Runner"
    # If the IP is unknown, the following is retured:
    # ,,,,,IP_NOT_FOUND
    # The number of commas can vary
    attr_accessor :ip, :country, :region, :city, :lat, :long, :error_message, :valid

    def initialize(ip, maxmind_string)
      self.ip = ip
      if maxmind_string =~ /IP_NOT_FOUND$/
        self.error_message = 'IP_NOT_FOUND'
        self.valid = false
      else
        self.country, self.region,self.city, self.lat, self.long = maxmind_string.split ','
        self.valid = true
      end
    end

    def to_s
      if valid?
        "IP: #{ip}\nCountry: #{country}\nRegion: #{region}\nCity: #{city}"
      else
        "IP:#{ip}\nError: IP Not Found"
      end
    end

    def valid?
      valid
    end
  end
  
end

