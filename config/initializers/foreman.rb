# fix foreman stdout buffering. see:
# http://stackoverflow.com/questions/8717198/foreman-only-shows-line-with-started-wit-pid-and-nothing-else
$stdout.sync = true
