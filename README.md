[![Linux CI](https://github.com/konovod/simplepool/actions/workflows/linux.yml/badge.svg)](https://github.com/konovod/simplepool/actions/workflows/linux.yml)
[![MacOS CI](https://github.com/konovod/simplepool/actions/workflows/macos.yml/badge.svg)](https://github.com/konovod/simplepool/actions/workflows/macos.yml)
[![Windows CI](https://github.com/konovod/simplepool/actions/workflows/windows.yml/badge.svg)](https://github.com/konovod/simplepool/actions/workflows/windows.yml)
[![API Documentation](https://img.shields.io/website?down_color=red&down_message=Offline&label=API%20Documentation&up_message=Online&url=https%3A%2F%2Fkonovod.github.io%2Fsimplepool%2F)](https://konovod.github.io/simplepool) 

# simplepool

Simple thread-safe pool for anything that is not thread-safe.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     simplepool:
       github: konovod/simplepool
   ```

2. Run `shards install`

## Usage

```crystal
require "simplepool"
# Note that `MyConnection.new` will be protected by mutex, so can be not thread-safe
pool = SimplePool(MyConnection).new { MyConnection.new(address, port) }
10.times do
  spawn do
    # get object from pool
    conn = pool.get
    work_with(conn)
    # don't forget to return it
    pool.return(conn)
  end
end
10.times do
  spawn do
    # safe version as you don't need to explicitely return it
    pool.use do |conn|
      work_with conn
      raise "error" # object will be returned to pool even after raise
    end
  end
end
```

Docs on API are available on https://konovod.github.io/simplepool

## Contributing

1. Fork it (<https://github.com/konovod/simplepool/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [konovod](https://github.com/konovod) - creator and maintainer
