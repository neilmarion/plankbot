module Plankbot
  module CodeReview
    class RemoveAssigned
      def self.execute(context)
        reviewer_ids = context[:pull_request].reviewers.map(&:id)
        chosen = context[:remaining].select{ |x| reviewer_ids.include? x.id }
        context[:chosen] = context[:chosen] + chosen

        context[:remaining].reject!{ |x| reviewer_ids.include? x.id }

        context
      end
    end
  end
end
