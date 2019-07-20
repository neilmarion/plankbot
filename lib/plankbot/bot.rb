module Plankbot
  class Bot < ::SlackRubyBot::Commands::Base
    delegate :client, to: :instance

    def self.run
      begin
        instance.run
      rescue Slack::Web::Api::Errors::SlackError
        raise("Invalid ENV['PLANKBOT_SLACK_API_TOKEN']")
      end
    end

    def self.instance
      Plankbot::App.instance
    end

    def self.call(client, data, _match)
      client.say(channel: data.channel, text: "Sorry <@#{data.user}>, I don't understand that command!", gif: 'understand')
    end
  end
end
