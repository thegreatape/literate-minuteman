web: bundle exec rails server thin -p $PORT -e $RACK_ENV 
resquework: env QUEUE=* TERM_CHILD=1 bundle exec rake resque:work
