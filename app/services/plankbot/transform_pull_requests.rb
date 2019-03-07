module Plankbot
  class TransformPullRequests
    TRIGGER_LABELS = [
      PickWithLeastAssignment::REVIEW_READY_LABEL,
      PickWithLeastAssignment::RELEASE_LABEL,
    ]

    REPO_LABELS = [
      {match: /first-circle-account/, label: "fca"},
      {match: /first-circle-app/, label: "fcc"},
      {match: /firstcircle\.ph/, label: "website"},
    ]

    THUMBS_UP = /\:\+1\:|👍/

    def self.execute(extracted_pull_requests)
      pull_requests = extracted_pull_requests.map do |pr|
        labels = pr["labels"].map { |x| x["name"] }
        next unless (labels & TRIGGER_LABELS).present?

        repo_label = get_repo_label(pr)
        labels << repo_label if repo_label

        comments = fetch_comments(pr["comments_url"])
        approvers = comments.map do |comment|
          next unless comment["body"].match? THUMBS_UP
          comment["user"]["login"]
        end.compact

        {
          title: pr["title"],
          url: pr["html_url"],
          github_id: pr["id"].to_s,
          requestor_github_id: pr["user"]["login"].to_s,
          labels: labels,
          approvers: approvers,
        }
      end

      pull_requests.compact
    end

    private

    def self.get_repo_label(pr)
      chosen_labels = REPO_LABELS.select do |rl|
        rl[:label] if pr["url"].match?(rl[:match])
      end

      chosen_labels.first[:label] if chosen_labels.present?
    end

    def self.fetch_comments(url)
      response = HTTParty.
        get(url + "?access_token=#{ENV["GITHUB_ACCESS_TOKEN"]}")
      response.parsed_response
    end
  end
end
