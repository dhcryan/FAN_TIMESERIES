#!/bin/bash
# filepath: /home/dhc99/FAN/Periodicity_Modeling/run_all.sh

GPU=0
export CUDA_VISIBLE_DEVICES=${GPU}

# Define arrays of models and periodic types
# Putting Transformer last since it has issues
models=("FAN" "FANGated" "MLP" "KAN" "Transformer")
periodic_types=("sin" "mod" "complex_1" "complex_2" "complex_3" "complex_4" "complex_5" "complex_6")

# Create a log directory
LOG_DIR="./Periodicity_Modeling/logs"
mkdir -p ${LOG_DIR}

# Loop through each model and periodic type
for modelName in "${models[@]}"; do
    for periodicType in "${periodic_types[@]}"; do
        echo "======================================"
        echo "Running: Model=${modelName}, Type=${periodicType}"
        echo "======================================"
        
        # Create output directory
        path="./Periodicity_Modeling/${periodicType}/${modelName}"
        mkdir -p ${path}
        
        log_file="${LOG_DIR}/${periodicType}_${modelName}.log"
        
        # Run with error handling
        {
            python3 -u Periodicity_Modeling/test.py \
            --model_name ${modelName} \
            --periodic_type ${periodicType} \
            --path ${path}
        } 2>&1 | tee ${log_file}
        
        # Check if previous command succeeded
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            echo "ERROR: Experiment failed for ${modelName} on ${periodicType}" | tee -a ${LOG_DIR}/errors.log
        fi
        
        sleep 2
    done
done

echo "All experiments completed!"
echo "Check ${LOG_DIR}/errors.log for any failed experiments"