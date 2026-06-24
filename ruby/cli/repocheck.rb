#!/usr/bin/env ruby
# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require "optparse"

API_BASE = "https://api.github.com"

options = {
  user: nil,
  token: ENV["GITHUB_TOKEN"],
  include_private: false,
  verbose: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby github_repo_check.rb --user USERNAME [--include-private]"

  opts.on("-u", "--user USERNAME", "GitHub username or org") do |v|
    options[:user] = v
  end

  opts.on("-t", "--token TOKEN", "GitHub token, or use GITHUB_TOKEN env var") do |v|
    options[:token] = v
  end

  opts.on("--include-private", "Include private repos. Requires token permissions.") do
    options[:include_private] = true
  end

  opts.on("-v", "--verbose", "Verbose output") do
    options[:verbose] = true
  end
end.parse!

unless options[:user]
  warn "ERROR: --user is required"
  warn "Example: ruby github_repo_check.rb --user mpople69"
  exit 1
end

def github_get(path, token: nil)
  uri = URI("#{API_BASE}#{path}")

  req = Net::HTTP::Get.new(uri)
  req["Accept"] = "application/vnd.github+json"
  req["X-GitHub-Api-Version"] = "2022-11-28"
  req["User-Agent"] = "ruby-github-repo-check"
  req["Authorization"] = "Bearer #{token}" if token && !token.empty?

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  [res.code.to_i, res.body, res]
end

def json_get(path, token: nil)
  code, body, res = github_get(path, token: token)

  case code
  when 200
    JSON.parse(body)
  when 404
    nil
  else
    warn "WARN: GET #{path} returned HTTP #{code}"
    warn body[0, 300]
    nil
  end
end

def repo_file_exists?(owner, repo, path, token: nil)
  encoded_path = path.split("/").map { |p| URI.encode_www_form_component(p) }.join("/")
  code, _body, = github_get("/repos/#{owner}/#{repo}/contents/#{encoded_path}", token: token)
  code == 200
end

def list_repos(user, token:, include_private:)
  repos = []
  page = 1

  loop do
    path =
      if include_private
        "/user/repos?affiliation=owner&per_page=100&page=#{page}"
      else
        "/users/#{user}/repos?type=owner&per_page=100&page=#{page}"
      end

    data = json_get(path, token: token)
    break unless data.is_a?(Array)
    break if data.empty?

    repos.concat(data.select { |r| r["owner"]["login"].casecmp?(user) })
    page += 1
  end

  repos
end

def status_icon(ok)
  ok ? "OK " : "MISS"
end

def check_repo_files(owner, repo, token:)
  checks = {
    "README.md" => repo_file_exists?(owner, repo, "README.md", token: token),
    "CONTRIBUTING.md" => repo_file_exists?(owner, repo, "CONTRIBUTING.md", token: token),
    "CODE_OF_CONDUCT.md" => repo_file_exists?(owner, repo, "CODE_OF_CONDUCT.md", token: token),
    ".github/SECURITY.md" => repo_file_exists?(owner, repo, ".github/SECURITY.md", token: token),
    ".github/PULL_REQUEST_TEMPLATE.md" => repo_file_exists?(owner, repo, ".github/PULL_REQUEST_TEMPLATE.md", token: token),
    ".github/dependabot.yml" => repo_file_exists?(owner, repo, ".github/dependabot.yml", token: token),
    ".github/ISSUE_TEMPLATE/bug_report.md" => repo_file_exists?(owner, repo, ".github/ISSUE_TEMPLATE/bug_report.md", token: token),
    ".github/ISSUE_TEMPLATE/feature_request.md" => repo_file_exists?(owner, repo, ".github/ISSUE_TEMPLATE/feature_request.md", token: token),
    ".github/ISSUE_TEMPLATE/security_note.md" => repo_file_exists?(owner, repo, ".github/ISSUE_TEMPLATE/security_note.md", token: token),
    ".github/ISSUE_TEMPLATE/config.yml" => repo_file_exists?(owner, repo, ".github/ISSUE_TEMPLATE/config.yml", token: token)
  }

  checks
end

def print_repo_report(repo, checks)
  name = repo["full_name"]
  visibility = repo["private"] ? "private" : "public"
  archived = repo["archived"] ? "archived" : "active"

  puts
  puts "== #{name} [#{visibility}, #{archived}]"

  checks.each do |file, ok|
    puts "  #{status_icon(ok)}  #{file}"
  end
end

user = options[:user]
token = options[:token]

puts "GitHub repo check for: #{user}"
puts "Using token: #{token && !token.empty? ? "yes" : "no"}"
puts

github_repo = json_get("/repos/#{user}/.github", token: token)
profile_repo = json_get("/repos/#{user}/#{user}", token: token)

puts "Account-level checks"
puts "--------------------"

if github_repo
  puts "#{status_icon(true)}  #{user}/.github exists"
  puts "#{status_icon(!github_repo["private"])}  #{user}/.github is public"

  github_checks = check_repo_files(user, ".github", token: token)

  [
    "README.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    ".github/SECURITY.md",
    ".github/PULL_REQUEST_TEMPLATE.md",
    ".github/dependabot.yml",
    ".github/ISSUE_TEMPLATE/bug_report.md",
    ".github/ISSUE_TEMPLATE/feature_request.md",
    ".github/ISSUE_TEMPLATE/security_note.md",
    ".github/ISSUE_TEMPLATE/config.yml",
    "profile/README.md"
  ].each do |file|
    ok = repo_file_exists?(user, ".github", file, token: token)
    puts "#{status_icon(ok)}  .github/#{file}"
  end
else
  puts "#{status_icon(false)}  #{user}/.github exists"
end

puts

if profile_repo
  puts "#{status_icon(true)}  #{user}/#{user} profile repo exists"
  puts "#{status_icon(!profile_repo["private"])}  #{user}/#{user} profile repo is public"
  puts "#{status_icon(repo_file_exists?(user, user, "README.md", token: token))}  #{user}/#{user}/README.md exists"
else
  puts "#{status_icon(false)}  #{user}/#{user} profile repo exists"
end

puts
puts "Repo checks"
puts "-----------"

repos = list_repos(user, token: token, include_private: options[:include_private])

if repos.empty?
  puts "No repos found, or API access failed."
  exit 1
end

repos.sort_by { |r| r["name"].downcase }.each do |repo|
  next if repo["name"] == ".github"
  next if repo["name"] == user

  checks = check_repo_files(user, repo["name"], token: token)

  if options[:verbose]
    print_repo_report(repo, checks)
  else
    missing = checks.select { |_file, ok| !ok }.keys

    puts
    puts "== #{repo["full_name"]} [#{repo["private"] ? "private" : "public"}]"
    if missing.empty?
      puts "  OK   all checked files present locally in repo"
    else
      puts "  Missing local files:"
      missing.each { |file| puts "    - #{file}" }
    end
  end
end

puts
puts "Notes"
puts "-----"
puts "- Missing local issue/PR templates may be fine if #{user}/.github is public."
puts "- Repos inherit defaults only when they do not have their own local file of that type."
puts "- Test issue templates with: https://github.com/#{user}/REPO/issues/new/choose"
