module Plankbot
  class TogglePresenceService
    attr_accessor :slack_id, :status, :note, :kind

    ONLINE = "online".freeze
    OFFLINE = "offline".freeze

    def initialize(slack_id:, status:, note:, kind:)
      @slack_id = slack_id
      @status = status
      @note = note
      @kind = kind
    end

    def execute
      current_time = DateTime.now
      reviewer = Plankbot::Reviewer.find_by(slack_id: slack_id)

      return unless reviewer

      last_presence = reviewer.presences.where(kind: kind).last

      if last_presence
        case status
        when ONLINE
          return false if last_presence.is_online
        when OFFLINE
          return false if !last_presence.is_online
        end

        last_presence.update_attributes(to: current_time)

        reviewer.presences.create({
          from: current_time,
          is_online: !last_presence.is_online,
          note: note,
          kind: kind,
        })
      else
        reviewer.presences.create({
          from: current_time,
          is_online: status == ONLINE ? true : false,
          note: note,
          kind: kind,
        })
      end

      return true
    end
  end
end
