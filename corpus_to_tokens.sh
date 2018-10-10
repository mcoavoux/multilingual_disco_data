
for corpus in dptb negra tiger_spmrl
do
    fold=data/${corpus}
    for t in dev test
    do
        discodop treetransforms ${fold}/${t}.discbracket --inputfmt=discbracket --outputfmt=tokens > ${fold}/${t}.tokens
    done
done

