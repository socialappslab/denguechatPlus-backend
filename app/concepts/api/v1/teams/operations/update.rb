# frozen_string_literal: true

module Api
  module V1
    module Teams
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          step :model
          step :update_organization
          tee :assign_house_blocks_to_new_members

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Teams::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def model
            @ctx[:model] = Team.kept.find_by(id: @params[:id])
            return Success({ ctx: @ctx, type: :success }) if @ctx[:model]

            errors = ErrorFormater.new_error(field: :base, msg: 'Team not found', custom_predicate: :not_found?)
            Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
          end

          def update_organization
            ActiveRecord::Base.transaction do
              begin
                @previous_member_ids = @ctx[:model].member_ids

                @ctx[:model].update!(@ctx['contract.default'].values.data)
                return Success({ ctx: @ctx, type: :success })
              rescue ActiveRecord::RecordInvalid
                add_errors(@ctx['contract.default'].errors, nil, I18n.t('errors.users.not_found'),
                           custom_predicate: :not_found?)
                Failure({ ctx: @ctx, type: :invalid, model: true })
                raise ActiveRecord::Rollback
              end
            end
          end

          def assign_house_blocks_to_new_members
            return unless @ctx['contract.default'].values.data.key?(:member_ids)

            team = @ctx[:model]
            current_member_ids = team.member_ids
            previous_member_ids = @previous_member_ids || []

            # Find members who are new to this team (either completely new or switching teams)
            members_to_assign = current_member_ids - previous_member_ids

            Rails.logger.info "assign_house_blocks called with #{members_to_assign.count} members to assign: #{members_to_assign}"
            return if members_to_assign.empty?

            # Remove existing house block assignments for these members
            UserProfileHouseBlock.where(user_profile_id: members_to_assign).destroy_all

            available_house_blocks = HouseBlock.joins(:wedges).where(wedges: { id: team.wedge_id }).to_a
            return if available_house_blocks.empty?

            members_to_assign.each_with_index do |member_id, index|
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
