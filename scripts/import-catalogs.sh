#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOGS_DIR="$SCRIPT_DIR/../catalogs"

echo -e "${BLUE}Importing MCP Catalogs...${NC}"
echo ""

if [ ! -d "$CATALOGS_DIR" ]; then
  echo -e "${RED}Error: Catalogs directory not found at $CATALOGS_DIR${NC}"
  exit 1
fi

cd "$CATALOGS_DIR"

for catalog in *.yaml; do
  if [ -f "$catalog" ]; then
    echo -e "${GREEN}Importing $catalog...${NC}"
    docker mcp catalog import "$catalog"
    
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✓${NC} Successfully imported $catalog"
    else
      echo -e "${RED}✗${NC} Failed to import $catalog"
    fi
    echo ""
  fi
done

echo -e "${BLUE}Import complete!${NC}"
echo ""
echo "View catalogs: docker mcp catalog ls"
echo "Show catalog:  docker mcp catalog show <name>"
