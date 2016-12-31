# RSpec::Parallel

[![wercker status](https://app.wercker.com/status/214cac59fa2938c9d373983bba71623e/m/master "wercker status")](https://app.wercker.com/project/byKey/214cac59fa2938c9d373983bba71623e)

Parallel spec runner for RSpec 3.

## Install

```sh
$ gem install parallel-rspec
```

## Getting Started / Usage

Parallel-rspec bundles `parallel-rspec` binary which can be used directly:

```sh
$ parallel-rspec spec
```

If spec/parallel_spec_helper.rb is found, the `parallel-rspec` command loads it before starting the test. Since parallel-rspec uses fork(2) to spawn off workers, you must ensure each worker runs in an isolated environment. Use the `after_fork` hook to reset any global state.

```ruby
RSpec::Parallel.configure do |config|
  config.after_fork do |worker|
    # Use separate database.
    ActiveRecord::Base.configurations["test"]["database"] << worker.number.to_s
    ActiveRecord::Base.establish_connection(:test)
  end
end
```

In this case, your workers assume sequence of databases exist and has right schema already. Rspec-parallel ships with `db:test:prepare_sequential` rake task to prepare them for your Rails application:

```sh
$ rake db:test:prepare_sequential
```

### Controll concurrency

The number of workers spawned by parallel-rspec is the number of available CPU cores by default. To controll the concurrency, use `concurrency` configuration option:

```ruby
RSpec::Parallel.configure do |config|
  config.concurrency = 4
end
```

`db:test:prepare_sequential` task takes concurrency as an argument.

```sh
$ rake "db:test:prepare_sequential[4]"
```

## License

[MIT](https://github.com/yuku-t/parallel-rspec/blob/master/LICENSE) © [Yuku TAKAHASHI](https://github.com/yuku-t)
