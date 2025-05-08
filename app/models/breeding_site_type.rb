# == Schema Information
#
# Table name: breeding_site_types
#
#  id             :bigint           not null, primary key
#  container_type :string
#  discarded_at   :datetime
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class BreedingSiteType < ApplicationRecord
  include Discard::Model

  has_many :additional_information, class_name: 'BreedingSiteTypeAditionalInformation', dependent: :destroy

  def serialized_additional_info
    host = Rails.env.production? ? 'https://miaplicacion.com' : 'http://localhost:3000'

    additional_information.map do |info|
      if info.only_image
        only_images(info, host)
      else
        only_text(info)
      end
    end
  end

  private

  def only_images(info, host)
    {
      description: info.description,
      url: Rails.application.routes.url_helpers.rails_blob_url(info.image, host: host),
      only_image: info.only_image
    }
  end

  def only_text(info)
    {
      title: info.title,
      subtitle: info.subtitle,
      description: info.description,
      only_image: info.only_image
    }
  end
end
