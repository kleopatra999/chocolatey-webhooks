require 'puppet_labs/github/event_base'
require 'puppet_labs/github/github_mix'

module PuppetLabs
module Github

# This class provides a model of a pull rquest.
#
# @see http://developer.github.com/v3/pulls/
class PullRequest < PuppetLabs::Github::EventBase
  include GithubMix
  # Pull request data
  attr_reader :author,
    :author_avatar_url

  # @!attribute [r] number
  #   @return [Numeric] The github issue number
  attr_reader :number

  # @!attribute [r] title
  #   @return [String] The title field of the github issue
  attr_reader :title

  # @!attribute [r] html_url
  #   @return [String] The URL to the github issue
  attr_reader :html_url

  # @!attribute [r] created_at
  #   @return [String] The pull request creation date
  attr_reader :created_at

  def self.from_data(data)
    new(:data => data)
  end

  def initialize(options = {})
    if json = options[:json]
      load_json(json)
    elsif data = options[:data]
      load_data(data)
    end
    if env = options[:env]
      @env = env
    else
      @env = ENV.to_hash
    end
  end

  def load_json(json)
    super

    load_data(@raw)
  end

  def load_data(data)

    pr = data['pull_request'] || data
    @number = pr['number']
    @title = pr['title']
    @html_url = pr['html_url']
    @body = pr['body']
    repo = data['repository'] || data['base']['repo']
    @repo_name = repo['name']

    # In the case that we're importing existing pull requests, we will be
    # directly querying the Github API which means the 'action' field will not
    # be included in the JSON structure.
    @action = data['action']
    @action = 'opened' if action.nil? && data['state'] == 'open'

    @created_at = pr['created_at']
    sender = data['sender'] || data['user']
    if sender
      @author = sender['login']
      @author_avatar_url = sender['avatar_url']
    end
  end

  def event_description
    "(pull request) #{repo_name} #{number}"
  end
end
end
end
