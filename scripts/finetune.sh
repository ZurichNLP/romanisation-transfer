#!/bin/sh

parent_model_dir=PATH_TO_PARENT_MODEL_DIR
parent_name=NAME_OF_PARENT_MODEL_CHECKPOINT
working_dir=PATH_TO_WORKING_DIRECTORY
nematus_home=PATH_TO_NEMATUS_REPOSITORY
valid_script=PATH_TO_VALIDATION_BASH_SCRIPT
model_dir=$working_dir/model

mkdir -p $model_dir

# Train nematus model
python3 $nematus_home/nematus/train.py \
    --source_dataset $working_dir/train.src \
    --target_dataset $working_dir/train.trg \
    --dictionaries $working_dir/vocab.json \
                   $working_dir/vocab.json \
    --save_freq 30000 \
    --model $model_dir/model \
    --reload latest_checkpoint \
    --model_type transformer \
    --embedding_size 512 \
    --state_size 512 \
    --tie_encoder_decoder_embeddings \
    --tie_decoder_embeddings \
    --loss_function per-token-cross-entropy \
    --label_smoothing 0.1 \
    --exponential_smoothing 0.0001 \
    --optimizer adam \
    --adam_beta1 0.9 \
    --adam_beta2 0.98 \
    --adam_epsilon 1e-09 \
    --learning_schedule constant \
    --learning_rate 0.001 \
    --no_reload_training_progress \
    --warmup_steps 4000 \
    --maxlen 200 \
    --batch_size 256 \
    --token_batch_size 16384 \
    --max_tokens_per_device 4500 \
    --valid_source_dataset $working_dir/dev.src \
    --valid_target_dataset $working_dir/dev.trg \
    --valid_batch_size 120 \
    --valid_token_batch_size 4096 \
    --valid_freq 10000 \
    --valid_script $valid_script \
    --disp_freq 1000 \
    --sample_freq 0 \
    --beam_freq 0 \
    --beam_size 4 \
    --translation_maxlen 200 \
    --normalization_alpha 0.6 \
    --patience 5 \
    --transformer_dropout_attn 0.1
