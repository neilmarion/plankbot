module Plankbot
  module CodeReview
    class RemoveRequestor
      def self.execute(context)
        requestor_id = context[:pull_request].requestor.id
        context[:remaining].reject!{ |x| x.id == requestor_id }
        context
      end
    end
  end
end
