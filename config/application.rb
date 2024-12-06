require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module VideoDialInRor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    if defined?(Rails::Server)
      config.after_initialize do
        claims = {
          application_id: "your app id",
          private_key: 'private.key'
        }
      
        config.token = Vonage::JWT.generate(claims)
        config.vclient = Vonage::Client.new(
          token: config.token,
          api_host: 'api-ap-3.vonage.com',
          rest_host: 'rest-ap-3.vonage.com')
         
          # if a call is created with a geo or region specific URL, it will be processed in the region corresponding to the endpoint used:

          # api-us.vonage.com: Virginia, or Oregon in case of fallback
          #   api-us-3.vonage.com: Virginia
          #   api-us-4.vonage.com: Oregon
          # api-eu.vonage.com: Dublin, or Frankfurt in case of fallback
          #   api-eu-3.vonage.com: Dublin
          #   api-eu-4.vonage.com: Frankfurt
          # api-ap.vonage.com: Singapore, or Sydney in case of fallback
          #   api-ap-3.vonage.com: Singapore
          #   api-ap-4.vonage.com: Sydney
      end
    end
  end
end
