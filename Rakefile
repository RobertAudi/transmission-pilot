require "rake/clean"
require "rubygems"
require "rubygems/package_task"

Gem::PackageTask.new(eval(File.read("transmission-pilot.gemspec"))) do |pkg|
end

task default: %i(clean clobber gem)

