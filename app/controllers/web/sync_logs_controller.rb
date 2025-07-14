module Web
  class SyncLogsController < ApplicationWebController
    include Pagy::Backend

    skip_before_action :verify_authenticity_token, only: %i[index show]

    before_action :http_authenticate

    def index
      scope = SyncLog.includes(:sync_log_errors).order(created_at: :desc)

      if params[:start_date].present?
        start_date = Date.parse(params[:start_date]).beginning_of_day
        scope = scope.where('created_at >= ?', start_date)
      end

      if params[:end_date].present?
        end_date = Date.parse(params[:end_date]).end_of_day
        scope = scope.where('created_at <= ?', end_date)
      end

      @pagy, @logs = pagy(scope, items: 10)
    end

    def show
      scope = SyncLogError.where(sync_log_id: params[:id])

      scope = scope.where('message ILIKE ?', "%#{params[:message]}%") if params[:message].present?
      scope = scope.where(item_id: params[:item_id].upcase) if params[:item_id].present?
      @sync_log = SyncLog.find_by(id: params[:id])
      @pagy, @errors = pagy(scope.order(created_at: :desc), items: 10)
    end
  end
end
