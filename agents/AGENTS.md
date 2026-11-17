When asked to use `bin/run`, always use local mode, eg. `bin/run --mode local rspec -v`

## Firefox testing

- Test Firefox locally with the Firefox Nightly deb at `/usr/lib/firefox-nightly/firefox`. The `/usr/bin/firefox` snap does not work with geckodriver.
- Selenium Manager caches geckodriver under `~/.cache/selenium/geckodriver/linux64/<version>/geckodriver`.
- In a throwaway system spec, register a driver and switch to it with `driven_by`:

  ```ruby
  Capybara.register_driver :firefox_nightly do |app|
    options = Selenium::WebDriver::Firefox::Options.new(binary: "/usr/lib/firefox-nightly/firefox", args: ["-headless"])
    service = Selenium::WebDriver::Service.firefox(path: Dir[File.expand_path("~/.cache/selenium/geckodriver/linux64/*/geckodriver")].max)
    Capybara::Selenium::Driver.new(app, browser: :firefox, options: options, service: service)
  end
  ```

## Git worktrees

- Create Git worktrees in `~/.cache/claude-worktrees/<repo>/<name>`, where Claude Code's worktree hook puts them, so all agents share one location. Do not create worktrees inside the repository, including `.claude/worktrees`.
