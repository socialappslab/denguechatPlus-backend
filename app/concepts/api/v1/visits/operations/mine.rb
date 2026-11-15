# frozen_string_literal: true

module Api
  module V1
    module Visits
      module Operations
        # The current brigadista's most recent visits, newest first, plus their visit count
        # for the last 30 days and the 30 days before.
        class Mine < ApplicationOperation
          include Dry::Transaction

          DEFAULT_LIMIT = 5
          MAX_LIMIT = 50

          step :list
          tee :meta
          tee :expose

          def list(input)
            @params = input[:params] || {}
            @visits = Visit.where(user_account: input[:current_user])
            limit = (@params[:limit].presence || DEFAULT_LIMIT).to_i.clamp(1, MAX_LIMIT)
            @ctx = { data: @visits.includes(:house, :visit_permission_option).latest_first.limit(limit) }
            Success({ ctx: @ctx, type: :success })
          end

          def meta
            now = Time.current
            @ctx[:meta] = {
              lastMonthCount: @visits.where(visited_at: 30.days.ago(now)..now).count,
              previousMonthCount: @visits.where(visited_at: 60.days.ago(now)...30.days.ago(now)).count
            }
          end

          def expose
            language = @params[:language]
            @ctx[:expose] = { language: language.in?(%w[en es pt]) ? language : 'es' }
          end
        end
      end
    end
  end
end
