rosruby_tf
==========

rosruby tf

These are experimental for now.

tf
--------------------

[tf](http://ros.org/wiki/tf) is ROS's basic multiple coordinate frames system.
rosruby_tf supports basic functions of tf.


### broad cast sample ###

```ruby
#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_tf")
require 'tf/broadcaster'

node = ROS::Node.new('/tf_test')
tf_broadcaster = Tf::TransformBroadcaster.new(node)

while node.ok?
  now = ROS::Time::now
  tf_broadcaster.send_transform([1.0, 2.0, 3.0], [0.0,0.0,0.0,1.0], now, '/base', '/shoulder')
  tf_broadcaster.send_transform([2.0, 1.0, 0.0], [0.0,0.0,0.0,1.0], now, '/shoulder', '/hand')

  sleep 1
end
```

### listener sample ###
```ruby
#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest('rosruby_tf')
require 'tf/listener'

node = ROS::Node.new('/tf_listener')
tf_listener = Tf::TransformListener.new(node)
stamp = ROS::Time.new

while node.ok?
  tf = tf_listener.lookup_transform('/base', '/hand', stamp)
  if tf
    p tf
  end
  sleep 1
end
```
