module Plankbot
  class ToggleAutoDeployment
    AUTO_DEPLOY_REDIS_KEY = "auto_deploy_key"

    def self.execute
      redis = Redis.new
      if redis.get(AUTO_DEPLOY_REDIS_KEY).blank?
        redis.set(AUTO_DEPLOY_REDIS_KEY, 0)
      end

      if redis.get(AUTO_DEPLOY_REDIS_KEY).to_i.zero?
        redis.set(AUTO_DEPLOY_REDIS_KEY, 1)

        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_CRITICAL_ISSUE_ANNOUNCEMENT_CHANNEL"],
          text: ":warning: Auto-deployment to production is disabled; although teams can still merge to master.",
          as_user: true,
        )
      else
        redis.set(AUTO_DEPLOY_REDIS_KEY, 0)

        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_CRITICAL_ISSUE_ANNOUNCEMENT_CHANNEL"],
          text: ":green_heart: Auto-deployment to production is enabled.",
          as_user: true,
        )
      end
    end
  end
end
