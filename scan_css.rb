#!/usr/bin/env ruby
class CSSHelper
  def initialize(file_name = nil)
    @files = file_name.nil? ? Dir['app/assets/stylesheets/**/*.*css*'] : [file_name]
  end

  def scan
    @files.each do |path|
      @file = File.open(path)
      @n = 0
      @file.lines.each do |line|
        @n = @n + 1
        match_line = line.lstrip.match(/^[.|#].*[\{]/)
        if match_line
          process_selectors(match_line)
        end
      end
    end
  end

  private

  def process_selectors(line)
    selectors_all = line.to_s.split(",")
    selectors_all.each do |inner_selectors|
      selectors = inner_selectors.strip.gsub(/{$|^.|#/,"")
      selectors.split(".").each do |selector|
        stop_pos = stop_position(selector)
        match_str = selector[0..stop_pos].strip
        match = `grep -R '#{match_str}' app/views/ app/helpers/ app/assets/javascripts`
        puts "#{match_str} is unused - #{@file.path} line #{@n}" if match.empty?
      end
    end
  end

  def strip_characters(selector)
    selector = selector.lstrip
  end

  def stop_position(selector)
    index = selector.lstrip.index(/[ |:|>|)]/) || 0
    index - 1
  end
end

file = ARGV[0]
CSSHelper.new(file).scan
