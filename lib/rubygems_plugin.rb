require 'rubygems/command_manager'

Gem::CommandManager.instance.register_command :isitjruby

Gem.pre_install do |i| # installer
  require 'isitjruby'

  next if i.instance_variable_defined? :@isitjruby_ran

  i.instance_variable_set :@isitjruby_ran, true

  spec = i.spec
  name = "#{spec.name} #{spec.version}"

  begin
    isitjruby = IsItJRuby.new i.spec
  rescue Gem::RemoteFetcher::FetchError
    i.say "uh-oh! unable to fetch data for #{name}, maybe it doesn't exist yet?"
    i.say "http://isitjruby.com/#{spec.name}"
    next
  end

  i.say

  if isitjruby.jruby? then
    i.say "#{name} is #{isitjruby.percent} verified JRuby"
  else
    comment = isitjruby.maybe_jruby?

    if comment then
      working = comment['version']
      i.say "#{name} might work, #{isitjruby.percent working} say #{working} works on JRuby"
    else
      i.say "Nobody has verified #{name} works with JRuby"
    end
  end

  i.say "Update #{isitjruby.url} with your experiences!"
  i.say
end

