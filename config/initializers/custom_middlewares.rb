require_relative '../../app/middlewares/version_supports'


Rails.application.config.middleware.insert_before Rack::Runtime, VersionSupports
