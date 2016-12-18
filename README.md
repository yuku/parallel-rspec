# RSpec::Parallel

Parallel spec runner for RSpec 3.

## Install

```sh
$ gem install rspec-parallel
```

## Getting Started / Usage

rspec-parallel bundles `rspec-parallel` binary which can be used directly:

```sh
$ rspec-parallel spec
```

If spec/parallel_spec_helper.rb is found, the `rspec-parallel` command loads it before starting the test. Since rspec-parallel uses fork(2) to spawn off workers, you must ensure each worker runs in an isolated environment. Use the `after_fork` hook to reset any global state.

```ruby
RSpec::Parallel.configure do |config|
  config.after_fork do |num|
    # Use separate database.
    ActiveRecord::Base.configurations["test"]["database"] << num.to_s
    ActiveRecord::Base.establish_connection(:test)
  end
end
```

In this case, your workers assume sequence of databases exist and has right schema already. Rspec-parallel ships with `db:test:prepare_sequential` rake task to prepare them for your Rails application:

```sh
$ rake db:test:prepare_sequential
```

### Controll concurrency

The number of workers spawned by rspec-parallel is the number of available CPU cores by default. To controll the concurrency, use `concurrency` configuration option:

```ruby
RSpec::Parallel.configure do |config|
  config.concurrency = 4
end
```

### Distributed mode

Rspec-parallel can be distributed over several servers. Set `bind` configuration option on a master server:

```ruby
RSpec::Parallel.configure do |config|
  config.bind = ["0.0.0.0", 4629]
end
```

Then execute set `upstream` configuration option on slave servers:

```ruby
RSpec::Parallel.configure do |config|
  config.upstream = [master_server_ip, 4629]
end
```

## License

[MIT](https://github.com/yuku-t/rspec-parallel/blob/master/LICENSE) © [Yuku TAKAHASHI](https://github.com/yuku-t)
