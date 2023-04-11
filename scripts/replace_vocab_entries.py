#!/usr/bin/env python3

import sys
import json
import random
from collections import OrderedDict


def read_vocab(filepath):
    '''Reads vocabulary file in nematus json format.'''
    with open(filepath) as infile:
        vocab = json.load(infile)
    return vocab


def main():
    '''Replaces unused items in a base vocabulary with unseen items from a new
    vocabulary. In transfer learning setups, the base vocabulary comes from the
    parent model and the new vocabulary from the child language pair.'''

    # Load the two vocabulary files and define up to where the base vocabulary
    # contains special items that should be kept
    base_vocab = read_vocab(sys.argv[1])
    new_vocab = read_vocab(sys.argv[2])
    special_symbols = range(int(sys.argv[3]))

    # Compute unused items in base vocab and unseen items in new vocab
    base_vocab_set = set(base_vocab.keys())
    new_vocab_set = set(new_vocab.keys())
    unused_base = base_vocab_set - new_vocab_set
    unseen_new = new_vocab_set - base_vocab_set

    # Identify which items can safely be replaced
    unused_base = [key for key in unused_base if base_vocab[key] not in special_symbols]

    # Insert unseen items at positions of unused items
    for new_item in unseen_new:
        to_replace = random.choice(unused_base)
        index = base_vocab[to_replace]
        base_vocab[new_item] = index
        del base_vocab[to_replace]
        unused_base.remove(to_replace)

    print(len(unseen_new), " items replaced")

    # Print new vocabulary in nematus format
    base_vocab = OrderedDict(sorted(base_vocab.items(), key=lambda x: x[1]))
    with open(sys.argv[2].rstrip('json')+".extended.json", "w") as outfile:
        json.dump(base_vocab, outfile, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    main()
