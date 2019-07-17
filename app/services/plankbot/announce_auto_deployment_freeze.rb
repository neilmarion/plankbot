module Plankbot
  class AnnounceAutoDeploymentFreeze
    AUTO_DEPLOY_REDIS_KEY = "auto_deploy_key"

    def self.execute
      redis = Redis.new

      if ENV["PLANKBOT_FREEZE_DEPLOYMENTS"].to_i.zero?
        return if redis.get(AUTO_DEPLOY_REDIS_KEY).to_i.zero? && !redis.get(AUTO_DEPLOY_REDIS_KEY).blank?

        redis.set(AUTO_DEPLOY_REDIS_KEY, ENV["PLANKBOT_FREEZE_DEPLOYMENTS"])

        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_CRITICAL_ISSUE_ANNOUNCEMENT_CHANNEL"],
          text: ":green_heart: Auto-deployment to production is enabled.",
          as_user: true,
        )
      else
        return if !redis.get(AUTO_DEPLOY_REDIS_KEY).to_i.zero? && !redis.get(AUTO_DEPLOY_REDIS_KEY).blank?

        redis.set(AUTO_DEPLOY_REDIS_KEY, ENV["PLANKBOT_FREEZE_DEPLOYMENTS"])

        PLANKBOT_SLACK_CLIENT.chat_postMessage(
          channel: ENV["PLANKBOT_CRITICAL_ISSUE_ANNOUNCEMENT_CHANNEL"],
          text: ":warning: Auto-deployment to production is disabled; although teams can still merge to master.",
          as_user: true,
        )
      end
    end
  end
end
