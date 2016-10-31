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

But the underlying `RSpec::Parallel::Worker` is built to be subclassed by your application. Since rspec-parallel uses fork(2) to spawn off workers, you must ensure each worker runs in an isolated environment. Use the `after_fork` hook with a custom worker to reset any global state:

```rb
class MySpecWorker < RSpec::Parallel::Worker
  def after_fork(num)
    # Use separate database.
    ActiveRecord::Base.configurations["test"]["database"] << num.to_s
    ActiveRecord::Base.establish_connection(:test)
  end
end
```

Specify your custom worker with `--worker` option. Note that spec_helper.rb must require the the worker.

```sh
$ rspec-parallel --worker=MySpecWorker spec
```

In addition, in this case, your workers assume sequence of databases exist and has right schema already. rspec-parallel ships with `db:test:prepare_sequential` rake task to prepare them for your Rails application:

```sh
$ rake db:test:prepare_sequential
```

### Controll concurrency

The number of workers spawned by rspec-parallel is the number of available CPU cores by default. To controll the concurrency, use `RSPEC_PARALLEL_CONCURRENCY` environment variable:

```sh
$ RSPEC_PARALLEL_CONCURRENCY=4 rake db:test:prepare_sequential # Prepare 4 databases then
$ RSPEC_PARALLEL_CONCURRENCY=4 rspec-parallel spec             # Run with 4 workers
```

### Distributed mode

rspec-parallel can be distributed over several servers. Execute rspec-parallel with `--bind` option in a master server:

```sh
$ rspec-parallel --bind=0.0.0.0:4629 spec
```

Then execute rspec-parallel with `--upstream` option in slave servers:

```sh
$ rspec-parallel --upstream=${master_server_ip}:4629 spec
```

## License

[MIT](https://github.com/yuku-t/rspec-parallel/blob/master/LICENSE) © [Yuku TAKAHASHI](https://github.com/yuku-t)
