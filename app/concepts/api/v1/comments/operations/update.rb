# frozen_string_literal: true

module Api
  module V1
    module Comments
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :transform_params
          step :check_if_can_be_updated
          tee :check_if_has_photo
          step :update_comment

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
            @params.delete(:action)
            @params.delete(:controller)
            @params[:user_account_id] = @current_user.id
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Comments::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def transform_params
            @data = @ctx['contract.default'].values.data
            @data.delete(:user_account_id)
          end

          def check_if_can_be_updated
            if @current_user.at_least?(Constants::Role::FACILITATOR)
              return Success({ ctx: @ctx,
                               type: :success })
            end
            if Comment.find_by(id: @data[:id]).user_account_id == @current_user.id
              return Success({ ctx: @ctx,
                               type: :success })
            end

            Failure({ ctx: @ctx, type: :invalid,
                      errors: ErrorFormater.new_error(
                        field: :base, msg: 'Only an admin/team leader or the owner can update this comment',
                        custom_predicate: :without_permissions
                      ) })
          end

          def check_if_has_photo
            @delete_photo = @data[:photo].nil? && @data[:delete_photo]
            @photo = @data[:photo] if @data[:photo].present?
            @data.delete(:delete_photo)
            @data.delete(:photo)
          end

          def update_comment
            begin
              comment = Comment.find_by(id: @data[:id])
              comment = manage_photos(comment)
              comment.update(@data)
              @ctx[:model] = comment
              @ctx[:model].instance_variable_set(:@current_user_id, @current_user.id)
              Success({ ctx: @ctx, type: :created })
            rescue StandardError => error
              errors = ErrorFormater.new_error(field: :base, msg: error,
                                               custom_predicate: :user_account_without_confirmation?)

              Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end

          def manage_photos(comment)
            comment.photo = @photo if @photo && !@delete_photo
            comment.photo.purge if @delete_photo && !@has_photo
            comment
          end
        end
      end
    end
  end
end
