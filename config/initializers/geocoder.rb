# frozen_string_literal: true

require 'geocoder'

Geocoder.configure(lookup: :google, api_key: ENV['GOOGLE_MAPS_API_KEY'])
