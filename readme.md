This repository contains the data and the scripts that are necessary to reproduce the study described in the Nodalida 2023 paper (and some additional tools, auxiliary files and pilot results not reported in the paper):

You say tomato, I say the same: A large-scale study of linguistic accommodation in online communities

The source corpora containing Flashback posts are not provided. You can download the scrambled xml files from the Språkbanken Text website and use the provided script large_xml_to_conllu2.rb to convert them to the conllu format. After that, they can be used as an input for the provided scripts.

The token frequency source file can be downloaded from here: http://demo.spraakdata.gu.se/sasha/flashback_uncased.zip. Unzip it and put it into the wordstats folder.

1. To reproduce the metric evaluation experiment (Section 2.3):

test_extract_users.rb: find 100 users for the evaluation experiment, create Text A and Text B (threshold = 3 * actual. If you want threshold 300, pass the value 900 to the script). You'll need flashback-fordon_sentence.conllu to run this file. 

test_mix_conllu_token.rb: mix the texts in each set, create 6 texts (threshold = 3 * actual). test_extract_users.rb must be run first.

test_delta.rb: run the ranking system (threshold = actual (pass 300 if you want 300)).
test_extract_users.rb and test_mix_conllu_token.rb have already been run, so you can run only test_delta.rb. It will use the files in the Sets10000-40000 folders.

test_wrapper2.rb will run all three scripts with all the settings (reproduce the whole experiment).

2. To reproduce the main experiment (Sections 2.4 and 3):

soclingprox2.rb -- for every pair of users finds if they have had a necessary number of interactions, outputs that and info about interaction dates (outputs int files). Launches extract_pairs.rb automatically.
extract_pairs.rb -- uses soclingprox2's output to extract the production of the relevant pairs and create the frequency vectors (outputs the pairs folders takes a lot of time due to reading huge CONLLU files). Launches process_pairs.rb automatically.
process_pairs.rb -- uses extract_pairs' output to calculated distances and output the results (distances and summary files).
output dir: dist
wrapper2.rb: reproduces the whole experiment
All results are stored in the dist folder (zipped).

permutations.rb performs the bootstrap statistical test.

EXTRAS:
supersummary.rb = summarize the results in dist in a convenient table

ttests_dist.rb: run t-tests on the output in dist (currently int vs no-int). Not reported in the paper.

contact: aleksandrs.berdicevskis@gu.se