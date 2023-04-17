for i in 1..10
    system "ruby soclingprox2.rb flashback-network#{i} 6000 5 3 365 10 366 both true farthest"
end
