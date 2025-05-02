DIR="tmp"

if [ ! -d "$DIR" ]; then
  mkdir -p "$DIR"
fi

# Default compiler
forge snapshot --snap ./tmp/.gas-solc.snap

# Solx compiler
FOUNDRY_PROFILE=solx forge snapshot --diff ./tmp/.gas-solc.snap