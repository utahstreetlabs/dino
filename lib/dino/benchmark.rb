module Dino
  module Benchmark
    def benchmark(description, &block)
      t1 = Time.now
      rv = yield
      t2 = Time.now
      elapsed = sprintf("%0.2f", (t2-t1)*1000)
      Dino.logger.info "#{description}: #{elapsed} ms" if Dino.logger
      rv
    end
  end
end
