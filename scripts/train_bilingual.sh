#!/bin/sh

working_dir=PATH_TO_WORKING_DIRECTORY
nematus_home=PATH_TO_NEMATUS_REPOSITORY
valid_script=PATH_TO_VALIDATION_BASH_SCRIPT
model_dir=$working_dir/model

mkdir -p $model_dir

# Train nematus model
python3 $nematus_home/nematus/train.py \
    --source_dataset $working_dir/train.src \
    --target_dataset $working_dir/train.trg \
    --dictionaries $working_dir/vocab.src.json \
                   $working_dir/vocab.trg.json \
    --save_freq 1200 \
    --model $model_dir/model \
    --reload latest_checkpoint \
    --model_type rnn \
    --embedding_size 512 \
    --state_size 1024 \
    --rnn_enc_depth 1 \
    --rnn_enc_transition_depth 2 \
    --rnn_dec_depth 1 \
    --rnn_dec_base_transition_depth 2 \
    --rnn_layer_normalisation \
    --rnn_dropout_embedding 0.5 \
    --rnn_dropout_hidden 0.5 \
    --rnn_dropout_source 0.3 \
    --rnn_dropout_target 0.3 \
    --tie_encoder_decoder_embeddings \
    --tie_decoder_embeddings \
    --loss_function per-token-cross-entropy \
    --label_smoothing 0.2 \
    --exponential_smoothing 0.0001 \
    --optimizer adam \
    --adam_beta1 0.9 \
    --adam_beta2 0.98 \
    --adam_epsilon 1e-09 \
    --learning_schedule constant \
    --learning_rate 0.0005 \
    --warmup_steps 4000 \
    --maxlen 200 \
    --batch_size 80 \
    --token_batch_size 1000 \
    --valid_source_dataset $working_dir/dev.src \
    --valid_target_dataset $working_dir/dev.trg \
    --valid_batch_size 40 \
    --valid_token_batch_size 500 \
    --valid_freq 400 \
    --valid_script $valid_script \
    --disp_freq 100 \
    --sample_freq 0 \
    --beam_freq 0 \
    --beam_size 5 \
    --translation_maxlen 200 \
    --normalization_alpha 0.6 \
    --patience 10
