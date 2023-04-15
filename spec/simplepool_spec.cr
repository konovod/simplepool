require "./spec_helper"

class SpecWorkspace
  @in_use = false
  @@in_init = false

  def initialize
    if @@in_init
      @@in_init = false
      raise "multithread access to `new`!"
    end
    @@in_init = true
    sleep 0.01
    @@in_init = false
  end

  def work
    if @in_use
      @in_use = false
      raise "multithread access to `work`!"
    end
    @in_use = true
    sleep 0.01
    @in_use = false
  end
end

describe SpecWorkspace do
  it "raises on simultaneous access" do
    space = SpecWorkspace.new
    done = Channel(Nil).new
    spawn do
      space.work
      done.send nil
    end
    spawn do
      sleep 0.001
      expect_raises(Exception) { space.work }
      done.send nil
    end
    done.receive
    done.receive
  end
end

describe SimplePool do
  it "can be created with Proc" do
    creater = ->{ Bytes.new(1024) }
    SimplePool(Bytes).new(8, creater)
  end

  it "can be created with block" do
    SimplePool(Bytes).new do
      Bytes.new(1024)
    end
  end

  it "can be created with default constructor" do
    SimplePool(Array(String)).new
  end

  it "can get and return objects" do
    pool = SimplePool(SpecWorkspace).new
    done = Channel(Nil).new
    10.times do
      spawn do
        # get object from pool
        conn = pool.get
        conn.work
        # don't forget to return it
        pool.return(conn)
        done.send nil
      end
    end
    10.times { done.receive }
  end

  it "can use objects" do
    pool = SimplePool(SpecWorkspace).new
    done = Channel(Nil).new
    10.times do
      spawn do
        # get object from pool
        pool.use do |conn|
          conn.work
        end
        done.send nil
      end
    end
    10.times { done.receive }
  end
end
