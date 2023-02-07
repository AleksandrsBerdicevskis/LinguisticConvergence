require 'rinruby'
o = File.open("dist\\summary.tsv","w:utf-8")
o.puts "threshold\tsubforum1\tsubforum2\tmode\tnpairs\tpositive\tave_diff\tiqr"

def iqr(filename)
    f2 = File.open(filename,"r:utf-8")
    array2 = []
    f2.each_line.with_index do |line, index|
        if index > 0
            line2 = line.strip.split("\t")
            array2 << line2[3].to_f
        end
    end
    #STDERR.puts array2.join(" ")
    R.assign "array2", array2
    iqr2 = R.pull "IQR(array2)"
    return iqr2
end

for i in 7..10 do
    STDERR.puts i
    #[3000,6000].each do |threshold|
    [3000].each do |threshold|
        STDERR.puts threshold
        f1 = File.open("dist\\flashback-network#{i}\\summary_#{threshold}_p3_t5_i10_df.tsv","r:utf-8")
        lines = f1.readlines
        iqri = iqr("dist\\flashback-network#{i}\\distances_#{threshold}_p3_t5_i10_df.tsv")
        iqrn = iqr("dist\\flashback-network#{i}\\distancesno_#{threshold}_p3_t5_i10_df.tsv")

        o.puts "#{threshold}\t#{lines[1].strip}\t#{iqri}"
        o.puts "#{threshold}\t#{lines[2].strip}\t#{iqrn}"

    end
end