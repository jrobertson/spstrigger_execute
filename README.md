# Introducing the SPStrigger_execute Gem

    require 'spstrigger_execute'

    url = 'http://www.jamesrobertson.eu/dynarex/sps-keywords.xml'
    ste = SPSTriggerExecute.new url
    a = ste.mae 'kit', 'motion detected

    #=> [[:rse, ["//job:wakeup", "http://a0.jamesrobertson.eu/qbx/r/dandelion_a3/power-mgmt.rsf", "kit"]], [:rse, ["//job:log", "http://a0.jamesrobertson.eu/qbx/r/motion.rsf", "kit"]], [:sps, "kit/output/led: 5 on duration 2"], [:sps, "niko2: awake"], [:sps, "mia: notify hello: James"]]

The above example show what happens when an SPS topic and message is passed into it. Returned is a couple of jobs to run as well as a couple of SPS messages to publish.

## Resources

* [spstrigger_execute]( https://rubygems.org/gems/spstrigger_execute)

spstriggerexecute gem sps trigger keywords
 
