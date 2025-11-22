#!/bin/bash

echo "Starting AOT and JIT tasks in parallel"

./sh/gvm.aot.sh &
./sh/gvm.jit.sh &

wait

echo "Both tasks completed!"