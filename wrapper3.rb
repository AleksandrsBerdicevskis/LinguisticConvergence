
for i in 10..10
    #system "ruby process_pairs.rb flashback-network#{i} 3000 5 3 365 10 366 yes farthest"
    system "ruby process_pairs.rb flashback-network#{i} 3000 5 3 365 10 366 no farthest"
    #system "ruby process_pairs.rb flashback-network#{i} 6000 5 3 365 10 366 yes farthest"
    #system "ruby process_pairs.rb flashback-network#{i} 6000 5 3 365 10 366 n farthest"
end

__END__
for i in 8..8
    system "ruby process_pairs.rb flashback-network#{i} 3000 5 3 365 10 366 yes farthest"
    system "ruby process_pairs.rb flashback-network#{i} 3000 5 3 365 10 366 no farthest"
    system "ruby process_pairs.rb flashback-network#{i} 6000 5 3 365 10 366 yes farthest"
    system "ruby process_pairs.rb flashback-network#{i} 6000 5 3 365 10 366 n farthest"
end
