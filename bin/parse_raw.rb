#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9'
require 'yaml'
require File.join(File.expand_path(File.dirname(__FILE__) + '/../lib'), 'metar')

filename = File.join(File.expand_path(File.dirname(__FILE__) + '/../data'), "stations.yml")
stations = YAML.load_file(filename)

stations.each_pair do |cccc, raw_text|
  raw = Metar::Raw.new(cccc, raw_text)
  report = nil
  begin
    report = Metar::Report.new(raw)
    report.analyze
    $stdout.print '.'
  rescue => e
    $stderr.puts "#{ raw.metar }"
    $stderr.puts "  Error: #{ e }"
    $stdout.print 'E'
  end
  if report.warnings.length > 0
    $stderr.puts "#{ raw.metar }"
    $stderr.puts "  Warning(s): " + report.warnings.join(', ')
    $stdout.print 'W'
  end
  $stdout.flush
end
