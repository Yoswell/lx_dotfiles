# Global colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'

# Logger functions
success() {
  echo -e "${GREEN}[✓]${NC} :: $1"
}

info() { # Success
  echo -e "${BLUE}[i]${NC} :: $1"
}

warning() { # Warning
  echo -e "${YELLOW}[!]${NC} :: $1"
}

error() { # Error
  echo -e "${RED}[✗]${NC} :: $1"
}

section() { # Banner
  echo -e "${CYAN}[ $1 ]${NC}"
}