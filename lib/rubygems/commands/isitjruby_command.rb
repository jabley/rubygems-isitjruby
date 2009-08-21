require 'rubygems/command'
require 'rubygems/version_option'
require 'rubygems/text'
require 'isitjruby'

##
# gem command for querying the jruby status of installed gems

class Gem::Commands::IsitJRubyCommand < Gem::Command

  include Gem::VersionOption
  include Gem::Text

  def initialize
    super 'isitjruby', 'Check isitjruby.com for JRuby compatibility',
          :version => Gem::Requirement.default

    add_version_option
  end

  def arguments # :nodoc:
    'GEMNAME       name of an installed gem to check for JRuby compatibility'
  end

  def defaults_str # :nodoc:
    "--version='>= 0'"
  end

  def usage # :nodoc:
    "#{program_name} GEMNAME [options]"
  end

  def execute
    name = get_one_gem_name

    dep = Gem::Dependency.new name, options[:version]
    specs = Gem.source_index.search dep

    if specs.empty? then
      alert_error "No installed gem #{dep}"
      terminate_interaction 1
    end

    spec = specs.last

    isitjruby = IsItJRuby.new spec

    comments = isitjruby.comments

    say "#{spec.name} #{spec.version}:    #{isitjruby.url}"

    say '    No reports!' if comments.empty?

    last_seen_version = nil

    comments.each_with_index do |comment, i|
      break if i > 0 and comment['version'] != last_seen_version

      works = comment['works_for_me'] ? 'works' : 'fails'
      platform = comment['platform'].values.join ' ' if comment['platform']

      msg = "#{comment['name']} says #{comment['version']} #{works}"
      msg << " on #{platform}" if platform

      say "    #{msg}"
      say format_text(comment['body'], 68, 8) unless comment['body'].empty?
      say

      last_seen_version = comment['version']
    end
  end

end
