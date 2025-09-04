module Slack
  class EventsController < BaseSlackController
    before_action :verify_slack_request!, only: :event unless Rails.env.development? && ENV["ALLOW_FAKE_SLACK"]

    def event
      case params[:type]
      when "url_verification"
        render html: params[:challenge].html_safe
      when "event_callback"
        ctl = ROUTES[params.dig(:event, :type).to_sym]&.constantize || raise("no controller for #{params.dig(:event, :type)}")
        return unless ctl
        ctl.dispatch(:handle, request, response)
        render json: { status: "ok" }
      end
    end

    private

    ROUTES = {
      app_home_opened: :AppHomesController,
    }
  end
end
