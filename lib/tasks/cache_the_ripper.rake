require 'ripper'
require 'sorcerer'

class CacheChecker < Ripper::SexpBuilder
  attr_reader :identifier_version

  def initialize(code, path)
    @identifier_version = {}
    @path = path
    super
  end

  def mark_cache_version(method, version)
    return if !method.is_a?(Array)
    if @in_cache_version && method[0] == :symbol
      @identifier_version[method[1][1]] = "version_#{version}"
      method[1][1] = "version_#{version}"
      @in_cache_version = false
    end
    if method[0] == :fcall && method[1][1] == "cache_version"
      @in_cache_version = true
    else
      method.each { |a| mark_cache_version(a, version) }
    end
  end

  def mark_partial_version(args)
    return if !args.is_a?(Array)
    if args[0] == :@tstring_content
      c = ApplicationController.new
      ps = c.lookup_context.view_paths.to_ary
      ps << File.dirname(@path)
      c.lookup_context.view_paths = ps
      file = c.lookup_context.find(args[1], [], true)
      path = file.inspect
      f = File.read(path)
      e = ERB::Compiler.new("").compile(f)[0]
      c = CacheChecker.new(e, path)
      sexpr = c.parse
      if not sexpr
        sexpr = c.parse
      end
      version = Zlib::crc32(Sorcerer.source(sexpr))
      args[1] = "version_#{version}"
    end
    args.each { |a| mark_partial_version(a) }
  end

  def on_command(method, args)
    if method[1] == "render"
      mark_partial_version(args)
    end
    super
  end

  def on_method_add_block(method, block)
    if method[1][0] == :fcall && method[1][1][1] == "cache"
      version = Zlib::crc32(Sorcerer.source(block))
      mark_cache_version(method, version)
      [:fcall, method]
    else
      super
    end
  end
end

namespace :cache_the_ripper do
  task :default => :environment do
    full_version_info = {}
    Dir['app/views/**/*.erb'].each do |path|
      f = File.read(path)
      e = ERB::Compiler.new("").compile(f)[0]
      c = CacheChecker.new(e, path)
      c.parse
      full_version_info.merge!(c.identifier_version)
    end

    File.open(File.join(Rails.root, "app", "views", "cache_version.json"), "w") do |f|
      f.write(JSON.generate(full_version_info))
    end
  end
end

task :cache_the_ripper => :'cache_the_ripper:default'

if Rake::Task.task_defined?("assets:precompile:nondigest")
  Rake::Task["assets:precompile:nondigest"].enhance do
    Rake::Task["cache_the_ripper"].invoke
  end
else
  Rake::Task["assets:precompile"].enhance do
    Rake::Task["cache_the_ripper"].invoke
  end
end
