require 'rinruby'
o = File.open("dist\\ttests.tsv","w:utf-8")
o.puts "duplet\tthreshold\tprop_p\tprop_x\tprop_df\tt_p\tt_t\tt_df"

for i in 1..6 do
    STDERR.puts i
    [3000,6000].each do |threshold|
        STDERR.puts threshold
        f1 = File.open("dist\\flashback-network#{i}\\distances_#{threshold}_p3_t5_i10_df.tsv","r:utf-8")
        f2 = File.open("dist\\flashback-network#{i}\\distancesno_#{threshold}_p3_t5_i10_df.tsv","r:utf-8")
        diffs1 = []
        positive1 = 0.0
        total1 = 0.0
        f1.each_line.with_index do |line,index|
            if index > 0
                line2 = line.strip.split("\t")
                total1 += 1
                positive1 += line2[4].to_i
                diffs1 << line2[3].to_f
            end
        end
        diffs2 = []
        positive2 = 0.0
        total2 = 0.0
        f2.each_line.with_index do |line,index|
            if index > 0
                line2 = line.strip.split("\t")
                total2 += 1
                positive2 += line2[4].to_i
                diffs2 << line2[3].to_f
            end
        end
        R.assign "diffs1", diffs1
        R.assign "diffs2", diffs2
        R.assign "positive1", positive1
        R.assign "positive2", positive2
        R.assign "total1",total1
        R.assign "total2",total2
        R.eval "p <- prop.test(c(positive1,positive2),c(total1,total2))"
        R.eval "t <- t.test(diffs1,diffs2)"
        prop_p = R.pull "p$p.value"
        prop_df = R.pull "p$parameter"
        prop_x = R.pull "p$statistic"
        t_p = R.pull "t$p.value"
        t_df = R.pull "t$parameter"
        t_t = R.pull "t$statistic"
        o.puts "#{i}\t#{threshold}\t#{prop_p}\t#{prop_x}\t#{prop_df}\t#{t_p}\t#{t_t}\t#{t_df}"
    end
end