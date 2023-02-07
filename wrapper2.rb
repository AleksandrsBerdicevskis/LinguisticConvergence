for i in 7..7
    system "ruby soclingprox2.rb flashback-network#{i} 12000 5 3 365 10 366 both true farthest"
end

__END__

for i in 7..10
    system "ruby soclingprox2.rb flashback-network#{i} 6000 5 3 365 10 366 both true farthest"
end


#for i in 1..6
#    system "ruby soclingprox2.rb flashback-network#{i} 6000 5 3 365 10 366 both true farthest"
#end

#for i in 1..6
#    system "ruby soclingprox2.rb flashback-network#{i} 12000 5 3 365 10 366 both true farthest"
#end


__END__
for i in 1..6
    system "ruby soclingprox2.rb flashback-network#{i} 12000 5 3 365 10 366 both true farthest"
end

__END__
for i in 1..6
    system "ruby soclingprox2.rb flashback-network#{i} 6000 5 3 365 10 366 both false closest"
end


__END__
system "ruby soclingprox2.rb flashback-network2 6000 5 3 365 10 366 both false closest"
system "ruby soclingprox2.rb flashback-network4 6000 5 3 365 10 366 both false closest"
system "ruby soclingprox2.rb flashback-network5 6000 5 3 365 10 366 both false closest"

system "ruby soclingprox2.rb flashback-network3 6000 5 3 365 10 366 both false farthest"
system "ruby soclingprox2.rb flashback-network6 6000 5 3 365 10 366 both false farthest"
system "ruby soclingprox2.rb flashback-network3 6000 5 3 365 10 366 both false closest"
system "ruby soclingprox2.rb flashback-network6 6000 5 3 365 10 366 both false closest"
