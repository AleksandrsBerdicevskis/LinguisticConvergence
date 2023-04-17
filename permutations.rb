
perms = 10000
o = File.open("bootstrap.tsv","w:utf-8")
o.puts "duplet\tp_positive\tp_change"

[1,3,4,5,6,7,8,9,10].each do |j|
    
    STDERR.puts j
    diffs = []
    f1 = File.open("dist\\flashback-network#{j}\\distances_3000_p3_t5_i10_df.tsv","r:utf-8")
    
    f1.each_line.with_index do |line,index|
        if index > 0
            diffs << line.strip.split("\t")[3].to_f
        end
    end
    
    f2 = File.open("dist\\flashback-network#{j}\\distancesno_3000_p3_t5_i10_df.tsv","r:utf-8")
    
    int_length = diffs.length
    
    f2.each_line.with_index do |line,index|
        if index > 0
            diffs << line.strip.split("\t")[3].to_f
        end
    end
    
    f3 = File.open("dist\\flashback-network#{j}\\summary_3000_p3_t5_i10_df.tsv","r:utf-8")
    
    ref_positive_int = nil
    ref_total_int = nil
    ref_positive_noint = nil
    ref_total_noint = nil
    
    f3.each_line.with_index do |line,index|
        if index == 1
            ref_positive_int = line.strip.split("\t")[5].to_f
            ref_total_int = line.strip.split("\t")[4].to_f
        elsif index == 2
            ref_positive_noint = line.strip.split("\t")[5].to_f
            ref_total_noint = line.strip.split("\t")[4].to_f
        
        end
    end
    
    ref_positive_delta = ref_positive_int - ref_positive_noint
    ref_total_delta = ref_total_int - ref_total_noint
    STDERR.puts "refs"
    STDERR.puts ref_positive_delta
    STDERR.puts ref_total_delta
    
    
    total_length = diffs.length
    noint_length = total_length - int_length
    STDERR.puts "sanity check"
    STDERR.puts diffs.length
    
    p_positive = 0.0
    p_total = 0.0
    
    
    diffs.shuffle!
    
    for i in 1..perms
        sample = (0..total_length).to_a.sample(int_length)
        
        
        
        positive_int = 0.0
        total_int = 0.0
        
        positive_noint = 0.0
        total_noint = 0.0
        
        
        
        diffs.each.with_index do |diff,index|
            if sample.include?(index)
                total_int += diff
                if diff > 0
                    positive_int += 1
                end
            else
                total_noint += diff
                if diff > 0
                    positive_noint += 1
                end
            end
        end
        
        positive_delta = (positive_int / int_length) - (positive_noint / noint_length)
        total_delta = (total_int / int_length) - (total_noint / noint_length)
        #STDERR.puts positive_delta
        #STDERR.puts total_delta
        if positive_delta >= ref_positive_delta
            p_positive += 1
        end
        if total_delta >= ref_total_delta
            p_total += 1
        end
    
    
    end
    
    STDERR.puts "ps"
    STDERR.puts p_positive/perms
    STDERR.puts p_total/perms
    o.puts "#{j}\t#{p_positive/perms}\t#{p_total/perms}"
    
end