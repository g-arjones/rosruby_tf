# tf/transformer.rb
#
#
require 'tf/quaternion'
require 'matrix'

class Matrix
  def []=(i,j,x)
    @rows[i][j]=x
  end
end

module Tf
  class Transform

    # @param [Transform] parent
    # @param [String] frame_id
    # @param [ROS::Time] stamp
    def initialize(pos=[0.0, 0.0, 0.0],
                   rot=[0.0, 0.0, 0.0, 1.0],
                   parent=nil, frame_id='', stamp=nil)
      @frame_id = frame_id
      @parent = parent
      @pos = pos
      @rot = rot
      @stamp = stamp
    end

    def self.from_matrix(mat, parent=nil, frame_id='', stamp=nil)
      q = Quaternion.from_matrix(mat)
      Transform.new([mat[0,3], mat[1,3], mat[2,3]],
                    q.to_a, parent, frame_id, stamp)
    end

    def to_matrix
      q = Quaternion.new(*@rot)
      mat = q.to_matrix
      mat[0,3] = @pos[0]
      mat[1,3] = @pos[1]
      mat[2,3] = @pos[2]
      mat
    end

    def to_s
      if @parent
        puts @parent
        "#{@frame_id} <= #{@parent.frame_id} : [#{@pos.join(",")}, #{@rot.join(",")}]"
      else
        "#{@frame_id} <= ROOT : [#{@pos.join(",")}, #{@rot.join(",")}]"
      end
    end

    def get_path(target)
      target_path = target.find_root
      self_path = self.find_root
      # same root
      if target_path.last.frame_id == self_path.last.frame_id
        while (not target_path.empty?) and (not self_path.empty?) and (target_path.last.frame_id == self_path.last.frame_id) do
          root = target_path.last
          target_path.pop
          self_path.pop
        end
        self_path + [root] + target_path.reverse
      else
        nil
      end
    end

    def find_root(path=[])
      if not @parent
        path.push(self)
      else
        @parent.find_root(path.push(self))
      end
    end

    def is_connected?(target)
      target_path = target.find_root
      self_path = self.find_root
      target_path.last == self_path.last
    end

    def get_transform_to(target)
      path = get_path(target)
      if path
        transform = Matrix::identity(4)
        for i in 0..(path.length-2)
          if path[i].parent == path[i+1]
            transform *= path[i].to_matrix.inverse
          else # this means next's parent is current
            transform *= path[i+1].to_matrix
          end
        end
        transform
      else
        nil
      end
    end

    attr_accessor :pos
    attr_accessor :rot
    attr_accessor :parent
    attr_accessor :frame_id
    attr_accessor :stamp

  end

  class TransformBuffer

    def initialize(max_buffer_length=100)
      @max_buffer_length = max_buffer_length
      @transforms = {}
    end

    attr_accessor :max_buffer_length

    def find_transform(frame_id, stamp=nil)
      if not @transforms[frame_id]
        return Transform.new([0.0, 0.0, 0.0],
                             [0.0, 0.0, 0.0, 1.0],
                             nil, frame_id, stamp)
      end
      if not stamp or stamp == ROS::Time.new
        # latest
        return @transforms[frame_id].last
      else
        @transforms[frame_id].each do |trans|
          if stamp >= trans.stamp
            return trans
          end
        end
      end
      nil
    end

    def add_transform(trans)
      if @transforms[trans.frame_id]
        @transforms[trans.frame_id].push(trans)
        if @transforms[trans.frame_id].length > @max_buffer_length
          @transforms[trans.frame_id].shift
        end
      else
        @transforms[trans.frame_id] = [trans]
      end
      # it is better to set parent again?
    end
  end

end
