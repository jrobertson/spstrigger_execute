#!/usr/bin/env ruby

# file: spstrigger_execute.rb

require 'dynarex'
require 'chronic_between'
require 'xmlregistry_objects'


class SPSTriggerExecute

  def initialize(x, reg=nil, polyrexdoc=nil)
    
    
    dx = if x.is_a? Dynarex then
    
      x
      
    else
      
      buffer, _ = RXFHelper.read x      
      Dynarex.new buffer
      
    end
    
    @patterns = dx.to_h
    
    if reg and polyrexdoc then
      
      xro = XMLRegistryObjects.new(reg, polyrexdoc)
      
      @h = xro.to_h      
      define_methods = @h.keys.map {|x| "def #{x}() @h[:#{x}] end"}      
      instance_eval define_methods.join("\n")      
      
    end

  end

  def match_and_execute(topicx, message)
    results = find_match topicx, message
    prepare_jobs(results)
  end

  alias mae match_and_execute

  private

  def find_match(topicx, message)

    @patterns.map.with_index.inject([]) do |r, row|

      h, i = row
      topic, msg,  conditions, job, index = h.values
      
      index ||= i + 1
      
      # note: the index is only present if there is a duplicate Dynarex record default key

      t, m = topic.length > 0, msg.length > 0

      result = if t && m then

        r1 = topicx.match(/#{topic}/)
        r2 = message.match(/#{msg}/)

        {topic: r1, msg: r2, index: index} if r1 && r2

      elsif t then

        r1 = topicx.match(/#{topic}/)
        {topic: r1, index: index} if r1

      elsif m then
      
        r2 = message.match(/#{msg}/)      
        {msg: r2, index: index} if r2
      else
        {}
      end

      if result and conditions.length > 0 then
        
        success = eval conditions
        result = nil unless success
      end

      result ? r << result : r
    
    end
  end

  def prepare_jobs(results)

    results.inject([]) do |r,h|

      a = []
      a += h[:topic].captures if h[:topic] && h[:topic].captures.any?
      a += h[:msg].captures if h[:msg]
      
      job = @patterns[h[:index].to_i - 1][:job]
      job_args = job.split + a
      
      if job[/^\/\//] then

        r << [:rse, job_args]
        
      else

        topic_message = job.gsub(/\$\d/) do |x| 

          i = x[/\d$/].to_i - 1
          x.sub(/\$\d/, a[i])
        end

        topic_message = topic_message\
          .gsub(/![Tt]ime/,Time.now.strftime("%a %H:%M%P"))\
          .gsub(/![Dd]ate/,Time.now.strftime("%d %b"))        

        topic_message.split(/\s*;\s*/).each do |m|
          
          r << [:sps, m]

        end
        
      end
      r  
    end
  end

  def time()

    t = Time.now
    
    def t.within?(times)
      ChronicBetween.new(times).within? Time.now
    end

    t
  end
end