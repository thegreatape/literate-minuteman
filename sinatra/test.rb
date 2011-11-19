require 'lookup'
require 'resque'

Resque.enqueue(ShelfLookupWorker, 2003928)
