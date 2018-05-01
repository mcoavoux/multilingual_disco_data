

corpus_data=corpus_data
tmp=${corpus_data}/tmp/negra

negtar=${corpus_data}/negra-corpus.tar.gz
negra=data/negra
depsyroot=${corpus_data}/tmp/

mkdir -p ${tmp}
mkdir -p ${negra}

if [ ! -e ${tmp}/negra ]
then
    tar xvzf ${negtar} --directory=${tmp}
fi

if [ ! -e  ${depsyroot}/cdg-2006-06-21 ]
then
    
    wget https://nats-www.informatik.uni-hamburg.de/pub/CDG/DownloadPage/cdg-2006-06-21.tar.gz
    tar xvzf cdg-2006-06-21.tar.gz --directory=${depsyroot}
    rm cdg-2006-06-21.tar.gz
    
    git clone https://github.com/jtbraun/Parse-RecDescent
    cp -r Parse-RecDescent/lib/Parse/ .
fi

# Comment out some lines in negraplugin that change tokenization in the corpus
sed -i '613 s/^/#/' ${depsyroot}/cdg-2006-06-21/grammar/negra/negraplugin.pl
sed -i '53,73 s/^/#/' ${depsyroot}/cdg-2006-06-21/grammar/negra/negraplugin.pl


${depsyroot}/cdg-2006-06-21/utils/depsy.pl -annos ${tmp}/negra.cdg -plugin ${depsyroot}/cdg-2006-06-21/grammar/negra/negraplugin.pl < ${tmp}/negra-corpus.export

treetools transform ${tmp}/negra-corpus.export ${tmp}/negra.export --src-enc iso-8859-1 --dest-enc utf-8

###--inputenc=iso-8859-1 --outputenc=utf-8

discodop treetransforms ${tmp}/negra.export ${tmp}/negra.discbracket --inputfmt=export --outputfmt=discbracket  --punct=move

python3 cdg2conll.py ${tmp}/negra.cdg ${tmp}/negra.discbracket ${negra}

#### 20602 sentences, 18602 train, 1000 test, 1000 dev
#### Dubey & Keller 2003
tail -1000  ${tmp}/negra.discbracket > ${negra}/dev.discbracket
tail -2000  ${tmp}/negra.discbracket | head -1000 > ${negra}/test.discbracket
head -18602 ${tmp}/negra.discbracket > ${negra}/train.discbracket

for corpus in train dev test
#for corpus in train
do
    echo
    python3 discbracket_to_ctbk.py ${negra}/${corpus}.conll ${negra}/${corpus}.discbracket ${negra}/${corpus}.ctbk --headrules data/headrules/negra.headrules --language negra > ${negra}/${corpus}_d2ctbk.log
    python3 ctbk.py ${negra}/${corpus}.ctbk ${negra}/${corpus}_silver.conll
    python3 eval_and_log_silver.py ${negra}/${corpus}.conll ${negra}/${corpus}_silver.conll ${negra}/${corpus}_silver.log
    python3 ctbk_to_raw.py ${negra}/${corpus}.ctbk ${negra}/${corpus}.raw
done



rm -rf ${corpus_data}/tmp






