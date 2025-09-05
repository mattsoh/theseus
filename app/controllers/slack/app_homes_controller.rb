module Slack
  class AppHomesController < BaseSlackController
    include Public::MailQuerying
    MAX_MAIL_COUNT = 90 # give us a little headroom...

    def handle
      return publish_home_view :no_user unless user_signed_in?

      check_the_mail current_public_user.email

      if @mail.count > MAX_MAIL_COUNT
        @mail = @mail.first(MAX_MAIL_COUNT)
        @truncated = true
      end

      publish_home_view :home
    end

    private

    def current_slack_id = @current_slack_id ||= params.dig(:event, :user)

    def current_public_user = @current_public_user ||= Public::User.find_by(slack_id: current_slack_id)

    def user_signed_in? = false && !!current_public_user

    def publish_home_view(template_name)
      SlackService.client.views_publish(
        user_id: current_slack_id,
        view: {
          type: "home",
          blocks: JSON.parse(render_to_string(template_name, formats: [:slack_blocks])),
        },
      )
    end
  end
end
