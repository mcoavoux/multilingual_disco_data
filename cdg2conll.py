

def read_cdg(filename) :
    morph_ats = set()
    text = open(filename, "r", encoding="latin1").read()
    corpus = []
    for chunk in text.split("\n\n") :
        lines = [ l.strip() for l in chunk.split("\n") if l.strip() ]
        if lines[0].startswith("//") :
            if not all([l.startswith("//") for l in lines]) :
                print("chunk", chunk)
            continue
        
        conlltree = []
        assert("'auto-s" in lines[0] and "<->" in lines[0])
        
        for i,line in enumerate(lines[1:]) :
            line = line.strip().split()
            assert(i == int(line[0]))
            
            id = line[1]
            dep = line[7]
            
            wordform = line[2].strip("'") if "\\'" not in line[2] else "'"
            
            deplabel = "punct" if line[5] == "''" else line[5].strip("'")
            
            morph = line[8:]
            if morph[0] == "/*" :
                assert ( "*/" in morph )
                morph = morph[morph.index("*/")+1:]
                
            morph = [ tok.rstrip(',;').replace("'","") for tok in morph ]
            
            #print(morph)
            #print(line)
            morph = dict([tuple(tok.split("/")) for tok in morph])
            pos = morph["cat"]
            del morph["cat"]
            
            for k in morph :
                if "|" in morph[k] :
                    morph[k] = morph[k].replace("|", "_").strip(")(")
            
            morph_ats |= set(morph)
            
            morph = "_" if len(morph) == 0 else "|".join(["=".join(t) for t in sorted(morph.items())])
            
            conlltree.append([id, wordform, "_", pos, pos, morph, dep, deplabel, "_", "_"])
        
        corpus.append(conlltree)
        
    
    print(morph_ats)
    
    return corpus

def get_toks_and_tags(filename):
    """reads a discbracket file and return list of (tok,tag) lists"""
    instream = open(filename)
    corpus = []
    for line in instream :
        toks = line.strip().replace("(", " ( ").replace(")", " ) ").split()
        
        tagtoks = [ (toks[i], toks[i+1]) for i in range(len(toks) -1) if toks[i] not in {"(", ")"} and toks[i+1] not in {"(", ")"} ]
        sentence = []
        for tag, tok in tagtoks :
            
            i, form = tok.split("=", 1)
            i = int(i)
            sentence.append((tag, form, i))
        
        sentence.sort(key = lambda x : x[2])
        
        corpus.append(sentence)
    return corpus

def print_conll(corpus, outstream) :
    for tree in corpus :
        for line in tree :
            outstream.write("{}\n".format("\t".join(line)))
        outstream.write("\n")

def insert_tag_tok(conll, tag_toks) :
    assert(len(conll) == len(tag_toks))
    
    for i in range(len(conll)) :
        assert(len(conll[i]) == len(tag_toks[i]))
        for j in range(len(conll[i])) :
            conll[i][j][1:5] = [tag_toks[i][j][1], "_", tag_toks[i][j][0], tag_toks[i][j][0]]
            

if __name__ == "__main__" :
    import sys
    import argparse
    
    usage = """Convert cdg dependency corpus to conll format"""
    parser = argparse.ArgumentParser(description = usage, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("input", help="input cdg file")
    parser.add_argument("discbracket", help="input discbracket file")
    parser.add_argument("outputdir", help="output directory")

    args = parser.parse_args()

    #filename="corpus_data/tmp/negra/negra.cdg"
    filename = args.input
    
    discfile = args.discbracket
    toks_and_tags = get_toks_and_tags(discfile)
    corpus = read_cdg(filename)
    
    insert_tag_tok(corpus, toks_and_tags)
    
    n_tokens = sum([len(sent) for sent in corpus])
    sys.stderr.write("Number of sentences : {}\n".format(len(corpus)))
    sys.stderr.write("Number of tokens    : {}\n".format(n_tokens))
    
    train = corpus[:-2000]
    test = corpus[-2000:-1000]
    dev = corpus[-1000:]
    
    for corpus,name in [(train, "train"), (dev, "dev"), (test, "test")] :
        outfile = "{}/{}.conll".format(args.outputdir, name)
        stream = open(outfile, "w", encoding="utf8")
        print_conll(corpus, stream)
        stream.close()




