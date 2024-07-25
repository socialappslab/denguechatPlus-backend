# frozen_string_literal: true

module Api
  module V1
    module GetLastParams
      module Queries
        class Index

          VersionParamStruct = Struct.new(:id, :version, :resource_name, :resource_data)

          include Api::V1::Lib::Queries::QueryHelper

          def initialize(filter)
            @model = VisitParamVersion
            @filter = filter
          end

          def self.call(...)
            new(...).call
          end

          def call
            visit_param_versions = @model.all unless @filter
            visit_param_versions = @model.where(name: @filter) if @filter
            create_data_hash(visit_param_versions)
          end

          private

          def create_data_hash(visit_param_versions, ignored_columns= %w[created_at discarded_at])
            visit_param_versions.map do |param_version|
              model = get_model(param_version)
              allowed_columns = get_allowed_columns(model, ignored_columns)
              data = get_data(model, allowed_columns)
              create_version_param(param_version, data)
            end
          end

          def get_model(param_version)
            param_version.name.classify.constantize
          end

          def get_allowed_columns(model, ignored_columns)
            model.column_names - ignored_columns
          end

          def get_data(model, allowed_columns)
            records = model.kept.select(*allowed_columns)
            records.map do |record|
              data = allowed_columns.map { |column| [column, record.send(column)] }.to_h
              if record.respond_to?(:photo) && record.photo.attached?
                data["photo_url"] = Rails.application.routes.url_helpers.url_for(record.photo)
              end
              data
            end
          end

          def create_version_param(param_version, data)
            VersionParamStruct.new(param_version.id, param_version.version, param_version.name, data)
          end

        end
      end
    end
  end
end
