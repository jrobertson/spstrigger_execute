#!/usr/bin/env ruby

# file: spstrigger_execute.rb

require 'dynarex'
require 'chronic_between'
require 'xmlregistry_objects'


class SPSTriggerExecute

  def initialize(x, reg=nil, polyrexdoc=nil, rws=nil, log: nil)
    
    log.info 'SPSTriggerExecute/initialize: active' if log
    
    @rws, @log = rws, log
    
    @patterns = if x.is_a? Dynarex then
    
      x.to_h
      
    elsif x.is_a? Array
      x
    else
      
      buffer, _ = RXFHelper.read x, auto: false
      dx = buffer[/^<\?dynarex /] ? Dynarex.new.import(buffer) : \
          Dynarex.new(buffer)
      dx.to_a
      
    end    
    
    
    
    if reg and polyrexdoc then
      log.info 'SPSTriggerExecute/initialize: before reg' if log      
      puts 'reg: ' + reg.inspect
      xro = XMLRegistryObjects.new(reg, polyrexdoc, log: log)
      log.info 'SPSTriggerExecute/initialize: after reg' if log      
      @h = xro.to_h      
      define_methods = @h.keys.map {|x| "def #{x}() @h[:#{x}] end"}      
      instance_eval define_methods.join("\n")      
      
      if log then
        log.info 'SPSTriggerExecute/initialize: define_methods : ' + 
            self.public_methods.sort.inspect
      end
    end

  end

  def match_and_execute(topic: nil, message: message)

    @log.info 'SPSTriggerExecute/match_and_execute: active' if @log
    results = find_match topic, message
    prepare_jobs(results)
  end

  alias mae match_and_execute
  
  def run(s)
    instance_eval s
  end
    

  private

  def find_match(topicx=nil, message)
    
    
    @patterns.map.with_index.inject([]) do |r, row|

      h, i = row

      topic, msg,  conditions, job = \
                      %i(topic msg conditions job).map {|x| h[x].to_s }
      
      index ||= i + 1
      
      # note: the index is only present if there is a duplicate
      #       Dynarex record default key

      t, m = topic.length > 0, msg.length > 0
      
      result = if topicx && t && m then

        r1 = topicx.match(/#{topic}/)
        r2 = message.match(/#{msg}/)

        {topic: r1, msg: r2, index: index} if r1 && r2

      elsif topicx && t then

        r1 = topicx.match(/#{topic}/)
        {topic: r1, index: index} if r1

      elsif m then

        r2 = message.match(/#{msg}/)      
        {msg: r2, index: index} if r2
      else
        {}
      end      

      if result and conditions.length > 0 then
        
        if @log then
          @log.info 'SPSTriggerExecute/find_match: conditions: ' + 
              conditions.inspect
        end

        named_match = message.match(/#{msg}/)
        
        variable_assignment = if named_match then
                  
          named_match.names.inject('') do |rs, name|

            m = msg =~ /\?<#{name}\>\\d+/ ? 'to_i' : 'to_s'
            rs << "#{name} = named_match[:#{name}].#{m}\n"            
          end
          
        else ''  
        end


        success = eval (variable_assignment + conditions)

        if @log then
          @log.info 'SPSTriggerExecute/find_match: success : '  + 
              success.inspect
        end
        
        result = nil unless success
      end

      result ? r << result : r
    
    end
  end

  
  # not yet implemented
=begin  
  def method_missing(method_name, *args)

    job = args.shift
    # Rsc object call goes here
    @log.debug 'package: ' + package.inspect
    @rws.run_job package=method_name, job, {}, args
  end  
=end  
  
  def prepare_jobs(results)
    
    @log.info 'SPSTriggerExecute/prepare_jobs: active' if @log

    results.inject([]) do |r,h|
      
      if @log then
        @log.info 'SPSTriggerExecute/prepare_jobs: inside inject h: ' + 
            h.inspect 
      end

      a = []
      a += h[:topic].captures if h[:topic] && h[:topic].captures.any?
      a += h[:msg].captures if h[:msg]
      
      params = {}
      params.merge!(h[:topic].named_captures) if h[:topic]
      params.merge!(h[:msg].named_captures) if h[:msg] 
      
      jobs = @patterns[h[:index].to_i - 1][:job]
      
      
      jobs.split(/\s*;\s*/).each do |job|

        job_args = job.split + a
        
        if job[/^\/\//] then

          r << [:rse, job_args, params]
          
        elsif job[/^[$\w\/]+:/]

          topic_message = job.gsub(/\$\d/) do |x| 

            i = x[/\d$/].to_i - 1
            x.sub(/\$\d/, a[i].to_s)
          end

          topic_message = topic_message\
            .gsub(/![Tt]ime/,Time.now.strftime("%a %H:%M%P"))\
            .gsub(/![Dd]ate/,Time.now.strftime("%d %b"))        

          
          r << [:sps, topic_message]          
        else
          
          statement = job.gsub(/\$\d/) do |x| 
            i = x[/\d$/].to_i - 1
            x.sub(/\$\d/, a[i].to_s)
          end
          
          r << [:ste, statement]
          
        end
      end
      
      @log.info 'SPSTriggerExecute/prepare_jobs: result: '  if @log
      
      r  
      
    end
  end

  def time()

    t = Time.now
    
    def t.within?(times)
      ChronicBetween.new(times).within? Time.now
    end

    def t.>(x)
      x.is_a?(String) ? self > Chronic.parse(x) : super(x)
    end

    def t.<(x)
      x.is_a?(String) ? self < Chronic.parse(x) : super(x)
    end    

    t
  end
    
end
