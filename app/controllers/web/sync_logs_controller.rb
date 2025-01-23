
module Web
  class SyncLogsController < ApplicationWebController
    include Pagy::Backend

    skip_before_action :verify_authenticity_token, only: [:index, :show]

    before_action :http_authenticate

    def index
      @pagy, @logs = pagy(SyncLog.includes(:sync_log_errors).order(created_at: :desc), items: 10)
    end

    def show
      @pagy, @errors = pagy(SyncLogError.where(sync_log_id: params[:id]).order(created_at: :desc), items: 10)
    end

  end
end
