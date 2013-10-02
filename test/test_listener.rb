#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_tf")

require 'test/unit'
require 'tf/listener'
require 'tf/broadcaster'

class TestTfListener < Test::Unit::TestCase
  def test_init
    node = ROS::Node.new('/tf_listener')
    tf_listener = Tf::TransformListener.new(node)
    sleep 1
    tf_broadcaster = Tf::TransformBroadcaster.new(node)
    sleep 1

    now = ROS::Time.now
    tf_broadcaster.send_transform([0.5, 0.0, 0.0],
                                  [0.0, 0.0, 0.0, 1.0],
                                  now,
                                  '/base', '/shoulder')
    tf_broadcaster.send_transform([0.0, -0.2, 0.0],
                                  [0.0, 0.0, 0.0, 1.0],
                                  now,
                                  '/shoulder', '/hand')
    tf_broadcaster.send_transform([0.0, 0.1, 0.1],
                                  [0.0, 0.0, 0.0, 1.0],
                                  now,
                                  '/hand', '/head')
    stamp = ROS::Time.new
    sleep 1

    tf = tf_listener.lookup_transform('/shoulder', '/hand', stamp)
    assert(tf)

    assert(!tf_listener.lookup_transform('/shoulder', '/hoge', stamp))
    assert(!tf_listener.lookup_transform('/age', '/hoge', stamp))
    assert(!tf_listener.lookup_transform('/age', '/shoulder', stamp))

    tf_hand = tf_listener.lookup_transform('/base', '/hand', stamp)
    assert(tf_hand)
  end
end
