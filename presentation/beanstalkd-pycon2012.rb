# encoding: utf-8

# My colors
R="\033[0;38;5;203m"
Y="\033[0;38;5;227m"
G="\033[0;38;5;32m"
O="\033[0;38;5;208m"
GR="\033[0;38;5;250m"
X="\033[0m"

section "Building A Cluster with Beanstalkd" do
end

slide <<-EOS, :block
    github.com/#{R}racheesingh#{X}      #{Y} Arista Networks #{X} 
    github.com/#{R}emaadmanzoor#{X}     #{Y} Yahoo! #{X}
    #{R}biju#{X}@bits-goa.ac.in         #{Y} BITS - Pilani, Goa Campus #{X}
EOS

section "Purpose and Background" do
    slide <<-EOS, :block
        #{Y}What We Want#{X}

        - #{R}Speed:#{X} Parallelism, visible speedup
        - #{R}Fault-tolerance:#{X} Master, slave
        - #{R}Open-source:#{X} Free
        - #{R}Fun:#{X} Python
    EOS
    slide <<-EOS, :block
        #{Y}Why Beanstalkd?#{X}
            
        - #{R}It's not MPICH:#{X} SSH deploys, fork-PID logic, pointers 
        - #{R}It's got bindings:#{X} Python, Ruby, Jave, et al
        - #{R}It's sized perfectly:#{X} RabbitMQ < Beanstalkd < Gearman
    EOS
    slide <<-EOS, :block
        #{Y}Distributed Message Queues#{X}
            
        - RabbitMQ, ZeroMQ
        - Celery
        - Gearman 
    EOS
    slide <<-EOS, :block
        #{Y}Today's Roadmap#{X}
            
        - Setup and test our prerequisites.
        - Setup and test Beanstalk{d,c} on our nodes.
        - A Monte-Carlo Algorithm: #{R}Distributed Estimation of π.#{X}
        - A More Useful Algorithm: #{R}Distributed Matrix Multiplication.#{X}
        - Enable and experiment with some basic fault tolerance. 
    EOS
end

section "Procuring The Ingredients" do
    slide <<-EOS, :block
        #{Y}The Basics#{X}

        - python-2.7.x
        - pip: python-distribute/python-setuptools
        - gcc: Some way to compile C source code
        - git
    EOS
    slide <<-EOS, :block
        #{Y}Useful Tabs#{X}

        - #{G}https://github.com/emaadmanzoor/beanstalkd-pycon2012-tutorial#{X}
        - #{G}https://github.com/kr/beanstalkd#{X}
        - #{G}https://github.com/earl/beanstalkc/#{X}
    EOS
    slide <<-EOS, :block
        #{Y}YAML#{X}
       
        #{R}libyaml:#{X}
            - brew install libyaml
            - pacman -S libyaml
            - Other package managers? 

        #{R}pyyaml:#{X}
            - pip install pyyaml
    EOS
    slide <<-EOS, :block
        #{Y}Beanstalk Client & Daemon#{X}
        
        #{R}Beanstalkd#{X}
            - git clone https://github.com/kr/beanstalkd
            - make
            - ./beanstalkd

        #{R}Beanstalkc#{X}
            - pip install beanstalkc
    EOS
end

section "Testing Your Setup" do
    slide <<-EOS, :center
        #{Y}Start Beanstalkd#{X}

        beanstalkd -l 127.0.0.1 -p 11300
    EOS
    slide <<-EOS, :code
        # Submit & Retrieve A Test Job

        >>> import beanstalkc
        >>> bean = beanstalkc.Connection(host='127.0.0.1', port=11300)
        >>> bean.put('Lala') 
        1
        >>> job = bean.reserve()
        1
        >>> job.body
        Lala
        >>> job.delete()  
    EOS
end

section "Now, we code" do
    slide <<-EOS, :block
        #{Y}Distributed π Estimation#{X}
        
                    Square Edge Length = #{O}2R#{X}
                    Square Area = #{O}(2R) ^ 2 = 4 * (R ^ 2)#{X}
                    Circle Area = #{O}π * (R ^ 2)#{X}

                    #{O}π = 4 * ( Circle Area / Square Area )#{X}

        #{R}Serial Algorithm#{X}
        
        - Randomly throw many darts into the defined square region.
        - Find the ratio of number of darts struck within the circle #{O}= C#{X}
          to the total number of darts thrown #{O}= N#{X}.
            
                    #{O}π = 4 x ( C / N )#{X}
    EOS

    slide <<-EOS, :block
        #{R}Parallel Algorithm#{X}
        
        - The more darts we throw, the more accurate our estimate will be.
        - Spawn many slaves, all throwing a number of darts in parallel.
        - Collect the #{O}C(i)#{X}'s from each worker and calculate the final estimate
          on the master.

                    #{O}π = 4 * ( ΣC(i) / N )#{X}

        #{R}Implementation Details#{X}
        
        - Queues: default and named (message-for-worker, message-for-master)
        - Parameters: number of darts to throw
        - Results: number of darts within the circle
        - Globals: size of the square
    EOS

    slide <<-EOS, :code
        # master.py
        # 
        # Our first master, does what a slave-driver does.

    EOS

    slide <<-EOS, :code
        # worker.py
        #
        # Our first slaves, simply echo their orders.

    EOS

    slide <<-EOS, :center
        #{Y}Does it work?#{X}
    EOS

    slide <<-EOS, :code
        # master.py
        #
        # Ramp up our efficiency; deadlines and dedicated queues 

    EOS

    slide <<-EOS, :code
        # worker.py
        #
        # Ramp up our efficiency; deadlines and dedicated queues 

    EOS

    slide <<-EOS, :center
        #{Y}Does it still work?#{X}
    EOS

    slide <<-EOS, :code
        # master.py
        #
        # Training's done, lets kick some π

    EOS

    slide <<-EOS, :code
        # worker.py
        #
        # Training's done, let's kick some π

    EOS

    slide <<-EOS, :center
        #{Y}Slide!#{X}
    EOS
end

section "The Beanstalk Protocol" do
    slide <<-EOS, :block
        #{Y}Implementation#{X}

        - Runs over TCP using ASCII.
        - Commands are processed and responded to
          in the same order in which they are received.
    EOS
    
    slide <<-EOS, :block
        #{Y}Job Cycle#{X}


              put <delay>               release <delay>
          ----------------> [DELAYED] <------------.
                                |                   |
                                | (time passes)     |
                                |                   |
           put <pr> <ttr>       v     reserve       |       delete
          -----------------> [READY] ---------> [RESERVED] --------> *poof*
                               ^  ^                |  |
                               |   \\  release <pr> |  |
                               |    `-------------'   |
                               |                      |
                               | kick                 |
                               |                      |
                               |       bury           |
                            [BURIED] <---------------'
                               |
                               |  delete
                                `--------> *poof*


        #{G}https://github.com/kr/beanstalkd/blob/master/doc/protocol.txt#{X}
        
        #{R}Other Commands#{X}
        
        - use #{O}<tube>#{X}, watch #{O}<tube>#{X}
        - peek #{O}<id>#{X}, peek-ready, peek-delayed, peek-buried
        - kick #{O}<bound>#{X}, kick-job #{O}id#{X}
        - stats-job #{O}<id>#{X}, stats-tube #{O}<tube>#{X}
    EOS
end

section "And we're done, thanks!" do
end

__END__
