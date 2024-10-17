# frozen_string_literal: true

module Api
  module V1
    module Comments
      module Operations
        class Show < ApplicationOperation
          include Dry::Transaction

          tee :params
          step :find_comment

          def params(input)
            @ctx = {}
            @params = to_snake_case(input[:params])
            @current_user = input[:current_user]
          end

          def find_comment
            @ctx[:data] = Comment.find_by(id: @params[:id])
            if @ctx[:data].nil?
              Failure({ ctx: @ctx, type: :not_found })
            else
              @ctx[:data].instance_variable_set(:@current_user_id, @current_user.id)
              is_admin = @current_user.has_role?(:admin)
              teams_managed = @current_user.has_role?(:team_leader) ? @current_user.teams_under_leadership : []
              comment_owner = UserAccount.find_by(id: @ctx[:data].user_account_id)
              is_team_leader = teams_managed.include?(comment_owner.teams.first&.id)
              @ctx[:data].instance_variable_set(:@current_user_is_admin, is_admin)
              @ctx[:data].instance_variable_set(:@is_team_leader, is_team_leader)
              Success({ ctx: @ctx, type: :success })
            end

          end
        end
      end
    end
  end
end
