module Plankbot
  class EtlPullRequests
    def self.execute
      return if Plankbot::Setting.is_shutdown?

      extracted_prs = ExtractPullRequests.execute
      transformed_prs = TransformPullRequests.execute(extracted_prs)
      LoadPullRequests.execute(transformed_prs)
    end
  end
end
