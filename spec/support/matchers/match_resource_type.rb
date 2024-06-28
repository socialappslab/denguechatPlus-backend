# frozen_string_literal: true

RSpec::Matchers.define(:match_resource_type) do |resource_type|
  match do |response|
    body = JSON.parse(response.body)
    params = body['data'].is_a?(Array) ? ['data', 0, 'type'] : %w[data type]
    body.dig(*params).eql?(resource_type)
  end
end
