module SlackService
  class << self
    def client = @client ||= Slack::Web::Client.new
  end
end