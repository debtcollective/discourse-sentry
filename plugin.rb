# name: discourse-sentry
# about: Discourse plugin to integrate Sentry (sentry.io)
# version: 1.0
# authors: debtcollective
# url: https://github.com/debtcollective/discourse-sentry

gem "sentry-raven", "2.9.0"

enabled_site_setting :discourse_sentry_enabled

PLUGIN_NAME ||= "DiscourseSentry".freeze

after_initialize do
  if SiteSetting.discourse_sentry_enabled && SiteSetting.discourse_sentry_dsn.present?
    Raven.configure do |config|
      config.dsn = SiteSetting.discourse_sentry_dsn
    end

    class ::ApplicationController
      before_action :set_raven_context

      private

      def set_raven_context
        Raven.user_context(id: current_user.id, username: current_user.username) if current_user
        Raven.extra_context(params: params.to_unsafe_h, url: request.url)
      end
    end
  end
end