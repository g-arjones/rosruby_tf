cmake_minimum_required(VERSION 2.8.3)
project(rosruby_tf)
find_package(catkin REQUIRED COMPONENTS rosruby)

catkin_package(
  CATKIN_DEPENDS rosruby
  )

rosruby_setup()
rosruby_generate_messages(tf2_msgs geometry_msgs)
rosruby_add_libraries(
  lib/tf.rb
  lib/tf)

install(PROGRAMS
  nodes/tf_broadcaster.rb
  nodes/tf_listener.rb
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})

install(DIRECTORY lib/
  DESTINATION ${ROSRUBY_LIB_DESTINATION}
  )
