# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bigquery"
  s.version = "0.2.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Bronte"]
  s.date = "2014-07-16"
  s.description = "This library is a wrapper around the google-api-client ruby gem.\nIt's meant to make calls to BigQuery easier and streamlined."
  s.email = "adam@brontesaurus.com"
  s.files = ["lib/bigquery.rb"]
  s.homepage = "https://github.com/abronte/BigQuery"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "A nice wrapper for Google Big Query"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<google-api-client>, [">= 0.4.6"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<byebug>, [">= 0"])
    else
      s.add_dependency(%q<google-api-client>, [">= 0.4.6"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
    end
  else
    s.add_dependency(%q<google-api-client>, [">= 0.4.6"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
  end
end
