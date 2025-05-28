# frozen_string_literal: true

module Api
  module V1
    module Posts
      module Operations
        class Update < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :validate_schema
          tee :transform_params
          step :check_if_can_be_updated
          tee :check_if_has_photo
          step :update_post

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
            @params.delete(:action)
            @params.delete(:controller)
            @params[:user_account_id] = @current_user.id
          end

          def validate_schema
            @ctx['contract.default'] = Api::V1::Posts::Contracts::Update.kall(@params)
            is_valid = @ctx['contract.default'].success?
            return Success({ ctx: @ctx, type: :success }) if is_valid

            Failure({ ctx: @ctx, type: :invalid })
          end

          def transform_params
            @data = @ctx['contract.default'].values.data
          end

          def check_if_can_be_updated
            return Success({ ctx: @ctx, type: :success }) if @current_user.has_role?(:admin) || @current_user.has_role?(:team_leader)
            return Success({ ctx: @ctx, type: :success }) if Post.find_by(id: @data[:id]).user_account_id == @current_user.id
            Failure({ ctx: @ctx, type: :invalid, errors: ErrorFormater.new_error(field: :base, msg: 'Only an admin/team leader or the owner can update this post', custom_predicate: :without_permissions )})
          end

          def check_if_has_photo
            @delete_photo = @data[:photos].nil? && @data[:delete_photo]
            @photo  = @data[:photos] if !@data[:photos].blank?
            @data.delete(:delete_photo)
            @data.delete(:photos)
            @data.delete(:user_account_id)
            @data.delete(:team_id)
          end

          def update_post
            begin
              post = Post.find_by(id: @data[:id])
              post = manage_photos(post)
              post.update(@data)
              @ctx[:model] = post
              @ctx[:model].instance_variable_set(:@current_user_id, @current_user.id)
              return Success({ ctx: @ctx, type: :created })
            rescue => error
              errors = ErrorFormater.new_error(field: :base, msg: error, custom_predicate: :user_account_without_confirmation? )

              return Failure({ ctx: @ctx, type: :invalid, errors: }) unless @ctx[:model]
            end
          end

          def manage_photos(post)
            if @photo && !@delete_photo
              post.photos = @photo
            end
            if @delete_photo && !@has_photo
              post.photos.purge
            end
            post
          end

          private

          def is_team_leader
            return false unless @current_user.has_role?(:team_leader)

            Post.find_by(id: @data[:id]).team_id.in? @current_user.teams_under_leadership
          end

        end
      end
    end
  end
end
