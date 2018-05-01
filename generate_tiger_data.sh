
corpus_data=corpus_data

tmp=${corpus_data}/tmp
mkdir -p ${tmp}


spmrl=corpus_data/GERMAN_SPMRL.tar.gz
tmpgerman=${tmp}/tiger

mkdir ${tmpgerman}

if [ ! -e ${tmpgerman}/GERMAN_SPMRL ]
then
    tar xvzf ${spmrl} -C ${tmpgerman}
    
    ## original corpus: 46234 50224 skipped in test (annotation error, cf Maier 2015)
    ## this line patch the corpus by removing 1 parent for each node with 2
    ## the links removed were chosen according to consistency with conll corpus
    sed -e '52143d;52160d;52192d;331199d;331200d;331206d;331207d;331208d;331214d;331254d;331261d' ${tmpgerman}/GERMAN_SPMRL/gold/xml/test/test.German.gold.xml > ${tmpgerman}/GERMAN_SPMRL/gold/xml/test/test.German.gold.xml_tmp
    cat ${tmpgerman}/GERMAN_SPMRL/gold/xml/test/test.German.gold.xml_tmp > ${tmpgerman}/GERMAN_SPMRL/gold/xml/test/test.German.gold.xml
fi

tiger=data/tiger_spmrl
mkdir -p ${tiger}

for corpus in train dev test
do

    treetools transform ${tmpgerman}/GERMAN_SPMRL/gold/xml/${corpus}/${corpus}.German.gold.xml ${tmpgerman}/${corpus}.export --src-format tigerxml --dest-format export
    
    discodop treetransforms ${tmpgerman}/${corpus}.export ${tiger}/${corpus}.discbracket --inputfmt=export --outputfmt=discbracket --punct=move
    
    sed -i 's/#LRB#/-LRB-/g' ${tiger}/${corpus}.discbracket
    sed -i 's/#RRB#/-RRB-/g' ${tiger}/${corpus}.discbracket
    
    python3 replace_brackets.py ${tmpgerman}/GERMAN_SPMRL/gold/conll/${corpus}/${corpus}.German.gold.conll ${tiger}/${corpus}.conll
    python3 discbracket_to_ctbk.py ${tiger}/${corpus}.conll ${tiger}/${corpus}.discbracket ${tiger}/${corpus}.ctbk --headrules data/headrules/negra.headrules --language german > ${tiger}/${corpus}_d2ctbk.log
    python3 ctbk.py ${tiger}/${corpus}.ctbk ${tiger}/${corpus}_silver.conll
    python3 eval_and_log_silver.py ${tiger}/${corpus}.conll ${tiger}/${corpus}_silver.conll ${tiger}/${corpus}_silver.log
    python3 ctbk_to_raw.py ${tiger}/${corpus}.ctbk ${tiger}/${corpus}.raw
done

rm -rf ${tmp}
