#!/bin/bash
# run_bench_avg: Run a benchmark executable 10 times and get averaged results from ChatGPT.
#
# Requirements:
#   - OPENAI_API_KEY must be set in your environment (see install_env.sh).
#   - Dependencies: jq, curl
#
# Usage:
#   run_bench_avg <executable>

# --- Check CLI arguments ---
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <executable>"
    exit 1
fi

EXEC="$1"

# --- Validate executable ---
if [ ! -x "$EXEC" ]; then
    echo "Error: '$EXEC' does not exist or is not executable."
    exit 1
fi

# --- Check dependencies ---
for dep in jq curl; do
    if ! command -v "$dep" &> /dev/null; then
        echo "Error: $dep is required but not installed."
        exit 1
    fi
done

# --- Check API key ---
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY environment variable is not set. Run install_env.sh first."
    exit 1
fi

# --- Run benchmark 10 times ---
results=""
for i in {1..24}; do
    echo "Running iteration $i.../24"
    output="$("$EXEC")"
    results="${results}\n=== Run $i ===\n${output}"
done

# --- Construct prompt for ChatGPT ---
prompt="The following is benchmark output from 24 runs of a C++ executable.
Each block shows timing results for several functions.

Please calculate the average of each \"time/iter\" value (e.g., 99.34us), and iter/sec(e.g., 13.75 K,M) and return the final result in the same benchmark table format for each sub benchmark, preserving the structure, headers, and alignment of the original output. 
Do not explain anything — just return the formatted benchmark result table along with the column header.

Here is the data:
$results"

# --- Prepare API request payload ---
json_payload=$(jq -n --arg prompt "$prompt" '{
  model: "gpt-3.5-turbo",
  messages: [
    { role: "system", content: "You are a benchmarking assistant that formats benchmark summaries." },
    { role: "user", content: $prompt }
  ]
}')

# --- Make the API request ---
response=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -d "$json_payload")

# --- Extract and display the formatted benchmark result ---
formatted_output=$(echo "$response" | jq -r '.choices[0].message.content')

echo -e "\n📊 bashGPT Averaged Benchmark Result:\n"
echo -e "$formatted_output"
