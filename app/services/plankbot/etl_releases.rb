module Plankbot
  class EtlReleases
    def self.execute
      extracted_releases = ExtractReleases.execute
      transformed_releases = TransformReleases.execute(extracted_releases)
      LoadReleases.execute(transformed_releases)
    end
  end
end
