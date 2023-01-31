require 'rinruby'
require_relative "C:\\Sasha\\D\\DGU\\CassandraMy\\extract_tools.rb"
require_relative "C:\\Sasha\\D\\DGU\\CassandraMy\\math_tools.rb"

istart = ARGV[0] #100
ifinish = ARGV[1] #109
ntokens = ARGV[2].to_i #9000
#ntexts = ARGV[3].to_i #6
dir = ARGV[3] #Sets1000
vectorlen = ARGV[4].to_i #300

def get_freqs_from_text(file,wordlist,ntokens)
    #absfreqs = Hash.new(0) 
    bag = []
    f = File.open(file,"r:utf-8")
    f.each_line do |line|
        if line.strip != ""
            word = line.strip.split("\t")[1].downcase
            bag << word
        end
    end
    
    relfreqs = {}
    wordlist.each do |word|
        relfreqs[word] = bag.count(word).to_f/ntokens
    end
    
    return relfreqs

end


wordlist = extract_wordlist("C:\\Sasha\\D\\DGU\\CassandraMy\\Gramino\\GeneralStatsSumTokensUpdated\\","flashback",vectorlen)

facit = File.open("#{dir}\\Set#{istart}_#{ifinish}Facit.tsv","r:utf-8")
facit_hash = Hash.new(0)
remote = Hash.new
facit.each_line.with_index do |line,index|
    if index > 0
        line2 = line.strip.split("\t")
        facit_hash[line2[0]] = []
        for i in 1..5
            facit_hash[line2[0]] << line2[i].to_f
            #STDERR.puts line2[i].to_f
            if line2[i].to_f == 1.0
                remote[line2[0]] = "xabcde"[i]
            end
        end
    end
end
#STDERR.puts "Remote", remote

predicted = File.open("#{dir}\\Set#{istart}_#{ifinish}Predicted#{vectorlen}.tsv","w:utf-8")
predicted.puts "Set\ta\tb\tc\td\te\trs\trp"

corrs = []
corrs2 = []
corr_total = 0.0
corr2_total = 0.0
ds = []
d_total = 0.0

for i in istart..ifinish do
    set = "Set#{i}"
    base = get_freqs_from_text("#{dir}\\#{set}\\base.conllu",wordlist,ntokens).values
    letterhash = {}
    ["a","b","c","d","e"].each do |letter|
        candidate = get_freqs_from_text("#{dir}\\#{set}\\text#{letter}.conllu",wordlist,ntokens).values
        letterhash[letter] = cosine_delta(base,candidate)
    end
    R.assign "actual",facit_hash[set]
    R.assign "predicted",letterhash.values
    R.eval "corr = cor.test(actual,predicted,method='spearman')$estimate"
    R.eval "corr2 = cor.test(actual,predicted,method='pearson')$estimate"
    corr = R.pull "corr"
    corr_total += corr
    corrs << corr
    corr2 = R.pull "corr2"
    corr2_total += corr2
    corrs2 << corr2
    d = letterhash[remote[set]]
    d_total += d
    ds << d
    predicted.puts "#{set}\t#{letterhash.values.join("\t")}\t#{corr}\t#{corr2}"
end

ave_corr = corr_total/corrs.length
ave_corr2 = corr2_total/corrs.length
R.assign "corrs", corrs
iqr1 = R.pull "IQR(corrs)"
R.assign "corrs2", corrs2
iqr2 = R.pull "IQR(corrs2)"
ave_d = d_total/corrs.length
R.assign "ds", ds
iqr3 = R.pull "IQR(ds)"

res = File.open("test_results.tsv","a:utf-8")
res.puts "#{dir}\t#{ntokens}\t#{vectorlen}\t#{ave_corr}\t#{iqr1}\t#{ave_corr2}\t#{iqr2}\t#{ave_d}\t#{iqr3}"
res.close
    