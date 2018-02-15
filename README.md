
# Multilingual Discontinuous Data

This repository contains scripts to generate data in the input format
of the [mtg parser](https://github.com/mcoavoux/mtg/).
Process three corpora: 

    bash generate_english_data.sh
    bash generate_tiger_data.sh
    bash generate_negra_data.sh

Dependencies:

- `python3`
- `java` (>= 1.8)
- [`discodop`](https://github.com/andreasvc/disco-dop/)

Data required (and not included):

- English:
    - `corpus_data/dptb.tar.bz2`   (discontinuous ptb, [Evang and Kallmeyer 2011](http://www.aclweb.org/anthology/W/W11/W11-2913.pdf))
    - `corpus_data/ptbIII.tar.gz` (PTB version 3)
- German (Tiger): `corpus_data/GERMAN_SPMRL.tar.gz`   (SPMRL version of TiGer corpus)
- German (Negra): `corpus_data/negra-corpus.tar.gz`


For English, the script uses the Stanford parser to convert the ptb
to conll dependency trees.

For the Negra corpus, the script uses a modified version of
[depsy](https://nats-www.informatik.uni-hamburg.de/CDG/DownloadPage)
to convert it to dependency trees (the modification just makes sure that
the tokenization is not changed by Depsy).


