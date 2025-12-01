#!/bin/bash

echo "Starting AOT and JIT tasks in parallel"

chmod +x ./sh/gvm.aot.sh
chmod +x ./sh/gvm.jit.sh

./sh/gvm.aot.sh
./sh/gvm.jit.sh

wait

chmod +x ./sh/generate_report.sh
./sh/generate_report.sh

echo "Both tasks completed!"

# su docker login
# chmod +x run.sh
# ./run.sh
