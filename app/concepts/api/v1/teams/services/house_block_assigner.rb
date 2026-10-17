# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Services
        class HouseBlockAssigner
          def self.assign(team:, member_ids:)
            Rails.logger.info "assign_house_blocks called with #{member_ids.count} members to assign: #{member_ids}"
            return if member_ids.empty?

            # Remove existing house block assignments for these members
            UserProfileHouseBlock.where(user_profile_id: member_ids).destroy_all

            available_house_blocks = HouseBlock.joins(:wedges).where(wedges: { id: team.wedge_id }).to_a
            return if available_house_blocks.empty?

            member_ids.each_with_index do |member_id, index|
              house_block = available_house_blocks[index % available_house_blocks.size]

              Rails.logger.info "Assigning member_id: #{member_id} to house_block_id: #{house_block.id}"

              UserProfileHouseBlock.create!(
                user_profile_id: member_id,
                house_block_id: house_block.id
              )
            end
          end
        end
      end
    end
  end
end
