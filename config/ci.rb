# Run using bin/ci

CI.run do
  step "Setup", "bundle exec ruby bin/setup --skip-server"

  step "Style: Ruby", "bundle exec rubocop"

  step "Security: Gem audit", "bundle exec bundler-audit"
  step "Security: Brakeman code analysis", "bundle exec brakeman --quiet --no-pager --exit-on-warn --exit-on-error"

  step "Testing: Run minitest suite", "bundle exec rails test"



  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end
end
