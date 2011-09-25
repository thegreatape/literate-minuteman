require 'main'
require 'resque'

Resque.enqueue(ShelfLookupWorker, 2003928)
