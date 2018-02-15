
corpus_data=corpus_data
tmp=${corpus_data}/tmp/english

mkdir -p ${tmp}


target=data/dptb
target_lth=data/dptb_lth

mkdir -p ${target}
mkdir -p ${target_lth}

ptbtar=${corpus_data}/ptbIII.tar.gz
dptbtar=${corpus_data}/dptb.tar.bz2

parser=stanford-parser-full-2016-10-31.zip


#if [ ! -e pennconverter.jar ]
#then
    #wget http://fileadmin.cs.lth.se/nlp/software/pennconverter/pennconverter.jar
#fi

if [ ! -e stanford-parser.jar ]
then
    wget http://nlp.stanford.edu/software/stanford-parser-full-2016-10-31.zip
    unzip ${parser} -d ${tmp}/.
    cp ${tmp}/stanford-parser-full-2016-10-31/stanford-parser.jar .
fi



tar xvfz ${ptbtar} --directory=${tmp}
tar xvfj ${dptbtar} --directory=${tmp}



discodop treetransforms --inputfmt=export --outputfmt=discbracket ${tmp}/dptb7.export ${tmp}/dptb7_o.discbracket

sed 's/\\//g' < ${tmp}/dptb7_o.discbracket > ${tmp}/dptb7.discbracket


sed -n 3915,43746p ${tmp}/dptb7.discbracket > ${target}/train.discbracket
sed -n 43747,45446p ${tmp}/dptb7.discbracket > ${target}/dev.discbracket
sed -n 45447,47862p ${tmp}/dptb7.discbracket > ${target}/test.discbracket

sed -n 3915,43746p ${tmp}/dptb7.discbracket > ${target_lth}/train.discbracket
sed -n 43747,45446p ${tmp}/dptb7.discbracket > ${target_lth}/dev.discbracket
sed -n 45447,47862p ${tmp}/dptb7.discbracket > ${target_lth}/test.discbracket
    

## train / dev / test split (chunk of code from )
WSJDIR=${tmp}/ptb/treebank_3/parsed/mrg/wsj/

cat $WSJDIR/0[2-9]/*.mrg $WSJDIR/1*/*.mrg $WSJDIR/2[0-1]/*.mrg > ${tmp}/train_ptb.mrg
cat $WSJDIR/22/*.mrg > ${tmp}/dev_ptb.mrg
cat $WSJDIR/23/*.mrg > ${tmp}/test_ptb.mrg


for corpus in train dev test
do
    java -cp stanford-parser.jar -Xmx2g edu.stanford.nlp.trees.GrammaticalStructure -basic -treeFile ${tmp}/${corpus}_ptb.mrg -conllx -language en-sd > ${target}/${corpus}.conll
    #java -cp stanford-parser.jar -Xmx2g edu.stanford.nlp.trees.GrammaticalStructure -basic -treeFile ${tmp}/${corpus}_ptb.mrg -conllx -language en-sd > ${target}/${corpus}.conll
    #java -jar pennconverter.jar -f ${tmp}/${corpus}_ptb.mrg -t ${target_lth}/${corpus}.conll -splitSlash=false
done


for dir in ${target}  #${target_lth}
do
    for corpus in  dev test train
    do
        
        #python3 replace_brackets.py ${dir}/${corpus}_o.conll ${dir}/${corpus}.conll
        python3 discbracket_to_ctbk.py ${dir}/${corpus}.conll ${dir}/${corpus}.discbracket ${dir}/${corpus}.ctbk --headrules data/headrules/ptb.headrules --language english > ${dir}/${corpus}_d2ctbk.log
        python3 ctbk.py ${dir}/${corpus}.ctbk ${dir}/${corpus}_silver.conll
        python3 eval_and_log_silver.py ${dir}/${corpus}.conll ${dir}/${corpus}_silver.conll ${dir}/${corpus}_silver.log
        python3 ctbk_to_raw.py ${dir}/${corpus}.ctbk ${dir}/${corpus}.raw
    done
done


rm -rf ${tmp}
