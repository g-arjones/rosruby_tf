#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_tf")

require 'test/unit'
require 'tf/transformer'


class TestTransformer < Test::Unit::TestCase
  def setup
    # root --- frame1 ---- frame2
    #       |           |
    #       |           -- frame3
    #       -- framea ---- frameb
    @root = Tf::Transform.new([0, 0, 0], [0, 0, 0, 1], nil, '/root')
    @frame1 = Tf::Transform.new([1, 0, 0], [0, 0, 0, 1], @root, '/frame1')
    @frame2 = Tf::Transform.new([1, 0, 0], [0, 0, 0, 1], @frame1, '/frame2')
    @frame3 = Tf::Transform.new([0, -1, 0], [0, 0, 0, 1], @frame1, '/frame3')
    @framea = Tf::Transform.new([-1, 0, 0], [0, 0, 0, 1], @root, '/framea')
    @frameb = Tf::Transform.new([1, 1, 0], [0, 0, 0, 1], @framea, '/frameb')
  end

  def test_root
    assert_equal([@frame3, @frame1, @root], @frame3.find_root)
    assert_equal([@frame2, @frame1, @root], @frame2.find_root)
    assert_equal([@frame1, @root], @frame1.find_root)
    assert_equal([@root], @root.find_root)
  end

  def test_path
    assert_equal([@framea, @root, @frame1, @frame3], @framea.get_path(@frame3))
    path = @frame2.get_path(@frame3)
    assert_equal([@frame2, @frame1, @frame3], @frame2.get_path(@frame3))
  end

  def test_transform_chain
    puts @framea.get_transform_to(@frame3)
    puts @frame3.get_transform_to(@framea)
    puts @root.get_transform_to(@frame3)
  end
end

class TestTransformBuffer < Test::Unit::TestCase
  def test_initialize
    buf = Tf::TransformBuffer.new(10)
    assert_equal(10, buf.max_buffer_length)
    buf.max_buffer_length = 100
    assert_equal(100, buf.max_buffer_length)
  end

  def test_add_find_transform
    buf = Tf::TransformBuffer.new(100)
    trans = Tf::Transform.new([0.1, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0], nil, '/base', ROS::Time.new)
    now = ROS::Time.now
    trans_now = Tf::Transform.new([0.1, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0], nil, '/base', now)
#    assert(!buf.find_transform('/base'))
    buf.add_transform(trans)
    assert_equal(trans, buf.find_transform('/base'))
    buf.add_transform(trans_now)
    assert_equal(trans_now, buf.find_transform('/base'))
    assert_equal(trans, buf.find_transform('/base', now))
  end
end
