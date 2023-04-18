# Simple thread safe pool for anything
#
# Example of usage:
# ```
# # Note that `MyConnection.new` will be protected by mutex, so can be not thread-safe
# pool = SimplePool(MyConnection).new { MyConnection.new(address, port) }
# 10.times do
#   spawn do
#     # get object from pool
#     conn = pool.get
#     work_with(conn)
#     # don't forget to return it
#     pool.return(conn)
#   end
# end
# 10.times do
#   spawn do
#     # safe version as you don't need to explicitely return it
#     pool.use do |conn|
#       work_with conn
#       raise "error" # object will be returned to pool even after raise
#     end
#   end
# end
#  ```
class SimplePool(T)
  # Creates a pool of type T, with initial capacity `size`. New instances of T are constructed using `factory` call
  def initialize(@size : Int32, factory : -> T)
    @factory = factory
    @pool = Array(T).new(@size) { @factory.call }
    @mutex = Mutex.new
  end

  # Creates a pool of type T, with initial capacity `size`. New instances of T are constructed using inline block
  def initialize(@size : Int32 = 1, &block : -> T)
    @factory = block
    @mutex = Mutex.new
    @pool = Array(T).new(@size) {
      @factory.call
    }
  end

  # Creates a pool of type T, with initial capacity `size`. New instances of T are constructed using `T.new`
  def self.new(size : Int32 = 1)
    new(size) { T.new }
  end

  # Returns object from a pool. Object should be returned to the pool later, otherwise it will be garbage collected.
  def get : T
    @mutex.lock
    if @pool.empty?
      object = @factory.call
    else
      object = @pool.pop
    end
    @mutex.unlock
    object
  end

  # Yield a block with object from a pool. Object will be automatatically returned to the pool after block completion
  def use(& : (T) -> U) : U forall U
    object = get
    begin
      yield(object)
    ensure
      self.return(object)
    end
  end

  # Returns object to the pool.
  #
  # Actually, you can even "return" objects that wasn't in pool initially, so use it as alternative form of filling pool
  def return(object : T)
    @mutex.lock
    @pool << object
    @mutex.unlock
  end
end
