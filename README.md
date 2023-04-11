# romanisation-transfer
Code for the Paper ["On Romanization for Model Transfer Between Scripts in Neural Machine Translation"](https://aclanthology.org/2020.findings-emnlp.223/)

## Motivation

Transfer learning is a popular strategy to improve the quality of low-resource machine translation. For an optimal transfer of the embedding layer, the child and parent model should share a substantial part of the vocabulary. This is not the case when transferring to languages with a different script. We explore the benefit of romanization in this scenario. Our results show that romanization entails information loss and is thus not always superior to simpler vocabulary transfer methods, but can improve the transfer between related languages with different scripts. This repository provides code for reproducing our experiments.

## Reproducing Our Results

### Data

We use the data from [OPUS-100](https://opus.nlpl.eu/opus-100.php) for training our NMT models.

For Amharic, Arabic, Chinese, French, German, Marathi, Russian, Tamil and Yiddish, you can use the data as it is provided (always paired with English). For Hebrew, Maltese and Serbo-Croation, we randomly subsampled the training data to create comparable low-resource settings to the other language pairs. This subsampled data can be found in the `data` folder.

### Romanization

We use two tools for romanization in our experiments: For `uroman`, install the corresponding repository from [here](https://github.com/isi-nlp/uroman). Then you can romanize any of the data files like this:

    bin/uroman.pl -l TRIPLE_LANG_CODE < INPUT > ROMANIZED_OUTPUT

For `uconv`, you can find the documentation [here](https://linux.die.net/man/1/uconv). You can use the command `uconv -L` to list all possible transliterations. Choose the desired transliteration and romanize e.g. the Russian data as follows:

    uconv -x Russian-Latin/BGN < INPUT > ROMANIZED_OUTPUT

### Subword Segmentation

For learning and applying BPE models, we use [SentencePiece](https://github.com/google/sentencepiece). We learn models on the individual language training data for bilingual models (and for transfer with original script) and on all languages for multilingual models. The bilingual models have a vocabulary size of 2,000 and the multilingual models a vocabulary size of 32,000 items. For multilingual models, we add target language identifiers at the beginning of every segment (<2lang>), and these can be protected from segmentation e.g. like this:

    spm_train --input=COMBINED_DATA --model_prefix=MODEL_NAME --vocab_size=32000 --character_coverage=0.9995 --model_type=bpe --shuffle_input_sentence=True --user_defined_symbols="<2ar>,<2en>,<2de>,<2fr>,<2ru>,<2zh>"

The data can then be split into subwords as usual, using:

    spm_encode --model=MODEL_NAME.model < INPUT > SEGMENTED_OUTPUT

And in reverse:

    spm_decode --model=MODEL_NAME.model < SEGMENTED_INPUT > OUTPUT

For the baseline models that use the original script, you can replace unused items in the multilingual parent vocabulary with unseen items from the bilingual child vocabulary using the following script:

    python scripts/replace_vocab_entries.py PARENT_VOCAB.json CHILD_VOCAB.json NUM_SPECIAL_SYM

All vocabulary files must be in [nematus](https://github.com/EdinburghNLP/nematus)-readable format. NUM_SPECIAL_SYM refers to the number of special symbols in the parent vocabulary. The resulting vocabulary will be saved in PARENT_VOCAB.extended.json.

### Deromanization

For training deromanization models, we split inputs on character-level and preserve space characters as ⌀ symbols:

    cat INPUT | tr ' ' '⌀' |  sed 's/./& /g' > SEGMENTED_OUTPUT

This format can be reversed with:

    cat SEGMENTED_INPUT | sed 's/ //g' | tr '⌀' ' ' > OUTPUT

### Model Training

Both for training the MT models and the deromanization models, we use [nematus](https://github.com/EdinburghNLP/nematus). All training scripts are located in the `scripts` folder (paths need to be adjusted before running). You also need to create a validation script that is used to evaluate performance during training for early stopping. To train a bilingual baseline model, run:

    bash scripts/train_bilingual.sh

To train a multilingual model, run:

    bash scripts/train_multilingual.sh

For finetuning the multilingual models on the child language pairs, first copy the relevant files from the parent model directory to the child model directory:

    cp PARENT_MODEL_DIR/checkpoint CHILD_MODEL_DIR/
    cp PARENT_MODEL_DIR/model-ITERATION.* CHILD_MODEL_DIR/

ITERATION stands for the specific checkpoint you want to continue training from. Then edit all paths in the `checkpoint` file and the `model-ITERATION.json` file you just created in the child model directory, such that they point to the relevant files in the child model directory. Then, run:

    bash scripts/finetune.sh

To train a character-level deromanization model, run:

    bash scripts/train_deromanization.sh

### Evaluation

For evaluation with BLEU and chrF, we use [sacreBLEU](https://github.com/mjpost/sacrebleu).

# Citation

If you use this repository, please cite our [paper](https://aclanthology.org/2020.findings-emnlp.223/):

    @inproceedings{amrhein-sennrich-2020-romanization,
    title = "On Romanization for Model Transfer Between Scripts in Neural Machine Translation",
    author = "Amrhein, Chantal  and
      Sennrich, Rico",
    booktitle = "Findings of the Association for Computational Linguistics: EMNLP 2020",
    month = nov,
    year = "2020",
    address = "Online",
    publisher = "Association for Computational Linguistics",
    url = "https://aclanthology.org/2020.findings-emnlp.223",
    doi = "10.18653/v1/2020.findings-emnlp.223",
    pages = "2461--2469",
    }
