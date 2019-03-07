module Plankbot
  class PickTeammate
    TEAM_LABELS = [
      "onboarding",
      "min",
      "mout",
      "prodeng",
      "data",
      "design",
      "management",
      "product",
      "qa",
    ]

    def self.execute(context)
      # NOTE: Multiple teams not yet supported
      team_label = context[:pull_request].labels.where(name: TEAM_LABELS).first
      return context unless team_label

      team_tag = Plankbot::Tag.find_by_name(team_label.name)
      return context unless team_tag

      teammate_ids = team_tag.reviewers.pluck(:id)
      teammates = context[:remaining].select{ |x| teammate_ids.include? x.id }

      return context unless teammates

      context[:chosen] = context[:chosen] + teammates
      context[:remaining].reject!{ |x| teammate_ids.include? x.id }
      context
    end
  end
end
