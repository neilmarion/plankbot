# Plankbot (✿◠‿◠)
Plankbot is a code reviewer assignment bot

## Installation
In your Gemfile
```ruby
gem 'plankbot'
```
Then run
```
rails g plankbot:initializer
rails plankbot:install:migrations
rake db:migrate
```
In your config/routes.rb
```
mount Plankbot::Engine => "/plankbot"
```

## Slack API Token
Set the `PLANKBOT_SLACK_API_TOKEN` in the ENV. Go [here](https://firstcircle.slack.com/apps/new/A0F7YS25R-bots) to create one.

## Github Access Token
Set the `GITHUB_ACCESS_TOKEN` in the ENV. Go [here](https://github.com/settings/tokens) to create one.

## Seeds
To create seed data

```ruby
available_tag = Plankbot::Tag.create(name: "Yes", kind: "availability")
not_available_tag = Plankbot::Tag.create(name: "No", kind: "availability")
time_1_tag = Plankbot::Tag.create(name: "06:00-15:00", kind: "time_available")
time_2_tag = Plankbot::Tag.create(name: "07:00-16:00", kind: "time_available")
time_3_tag = Plankbot::Tag.create(name: "08:00-17:00", kind: "time_available")
time_4_tag = Plankbot::Tag.create(name: "09:00-18:00", kind: "time_available")
onboarding_tag = Plankbot::Tag.create(name: "onboarding", kind: "team")
min_tag = Plankbot::Tag.create(name: "min", kind: "team")
mout_tag = Plankbot::Tag.create(name: "mout", kind: "team")
prodeng_tag = Plankbot::Tag.create(name: "prodeng", kind: "team")
data_tag = Plankbot::Tag.create(name: "data", kind: "team")
design_tag = Plankbot::Tag.create(name: "design", kind: "team")
management_tag = Plankbot::Tag.create(name: "management", kind: "team")
product_tag = Plankbot::Tag.create(name: "product", kind: "team")
qa_tag = Plankbot::Tag.create(name: "qa", kind: "team")
high_sensitivity_tag = Plankbot::Tag.create(name: "high_sensitivity", kind: "tier")
fcc_code_quality_check_tag = Plankbot::Tag.create(name: "fcc_code_quality_check", kind: "tier")
fca_code_quality_check_tag = Plankbot::Tag.create(name: "fca_code_quality_check", kind: "tier")

reviewers = {
  jessc: {name: "Jess", slack_id: "SLACKID", github_id: "jmalvinchin", tags: [available_tag, time_1_tag, min_tag]},
  dc: {name: "Dean", slack_id: "SLACKID", github_id: "dc-fc", tags: [available_tag, time_1_tag, min_tag]},
  earle: {name: "Earle", slack_id: "SLACKID", github_id: "erbunao", tags: [available_tag, time_4_tag, prodeng_tag]},
  francis: {name: "Francis", slack_id: "SLACKID", github_id: "sic-f", tags: [available_tag, time_4_tag, mout_tag]},
  nmfdelacruz: {name: "Neil", slack_id: "SLACKID", github_id: "neilmarion", tags: [available_tag, time_4_tag, onboarding_tag]},
  rickdtrick: {name: "Rick", slack_id: "SLACKID", github_id: "rickdtrick", tags: [available_tag, time_4_tag, onboarding_tag]},
  angelique: {name: "Anj", slack_id: "SLACKID", github_id: "angeliqueulep", tags: [available_tag, time_4_tag, prodeng_tag]},
  jan: {name: "Jan", slack_id: "SLACKID", github_id: "fc-janharold", tags: [not_available_tag, time_4_tag, design_tag]},
  tj: {name: "TJ", slack_id: "SLACKID", github_id: "tjpalanca", tags: [not_available_tag, time_4_tag, data_tag]},
  andrewe: {name: "Andrew E", slack_id: "SLACKID", github_id: "aescay", tags: [not_available_tag, time_4_tag, data_tag]},
  tony: {name: "Tony", slack_id: "SLACKID", github_id: "tonyennis145", tags: [not_available_tag, time_4_tag, management_tag, high_sensitivity_tag]},
  brian: {name: "Brian", slack_id: "SLACKID", github_id: "briandragon", tags: [not_available_tag, time_4_tag, management_tag]},
  jerico: {name: "Jerico", slack_id: "SLACKID", github_id: "jericoramirez", tags: [not_available_tag, time_4_tag, qa_tag]},
  jig: {name: "Jig", slack_id: "SLACKID", github_id: "JigFirstCircle", tags: [not_available_tag, time_4_tag, product_tag]},
  rj: {name: "RJ", slack_id: "SLACKID", github_id: "rjomosura", tags: [not_available_tag, time_4_tag, qa_tag]},
}

reviewers.each do |reviewer|
  value = reviewer.last
  reviewer = Plankbot::Reviewer.
    create({
    name: value[:name],
    slack_id: value[:slack_id],
    github_id: value[:github_id],
  })

  value[:tags].each do |tag|
    reviewer.reviewer_tag_relationships.create(tag: tag)
  end
end

labels = [
  "review_ready",
  "release",
  "onboarding",
  "min",
  "mout",
  "prodeng",
  "high_sensitivity",
  "fcc",
  "fca",
  "website",
  "fcc_code_quality_check",
  "fca_code_quality_check",
]

labels.each do |key|
  Plankbot::Label.create(name: key)
end

Plankbot::Setting.create({
  shutdown_times: ["18:00-06:00"],
  shutdown_week_days: ["Saturday", "Sunday"],
  shutdown_dates: ["2019-02-24"],
})
```

## Repo Versions

This is an extra feature of Plankbot that does not have anything to do with review assignment. This feature announces the new version of the repository.

```
Plankbot::RepoVersion.create({
  repo_name: "FCA",
  version: "",
  github_api_endpoint: "https://api.github.com/repos/carabao-capital/first-circle-account/releases",
  github_versions_url: "https://github.com/carabao-capital/first-circle-app/releases",
})

Plankbot::RepoVersion.create({
  repo_name: "FCC",
  version: "",
  github_api_endpoint: "https://api.github.com/repos/carabao-capital/first-circle-app/releases",
  github_versions_url: "https://github.com/carabao-capital/first-circle-app/releases",
})
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
