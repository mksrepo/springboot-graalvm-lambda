#!/bin/bash

echo "Starting AOT and JIT tasks in parallel"

chmod +x ./sh/gvm.aot.sh
chmod +x ./sh/gvm.jit.sh

./sh/gvm.aot.sh &
./sh/gvm.jit.sh &

wait

echo "Both tasks completed!"