# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Serializers
        class Mine < ApplicationSerializer
          set_type :visit

          attributes :id, :visited_at, :status

          attribute :house_reference_code do |visit|
            visit.house&.reference_code
          end

          attribute :permission_granted, &:visit_permission_granted?

          attribute :permission_label do |visit, params|
            option = visit.visit_permission_option
            next visit.visit_permission_other if option.nil?

            option.public_send("name_#{params[:language]}").presence || option.name_es
          end
        end
      end
    end
  end
end
