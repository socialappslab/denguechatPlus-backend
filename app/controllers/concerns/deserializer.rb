module Deserializer
  def to_snake_case!(params_to_convert = params)
    params_to_convert.to_unsafe_h.deep_transform_keys!(&:underscore)
  end
end
