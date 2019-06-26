module Plankbot
  class App < SlackRubyBot::Server
    def initialize(options = {})
      token = ENV['PLANKBOT_SLACK_API_TOKEN'] || raise("Missing ENV['PLANKBOT_SLACK_API_TOKEN']")
      super(token: token)
    end

    def self.instance
      @instance ||= new
    end
  end
end
