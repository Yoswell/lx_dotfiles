#!/bin/bash

source ~/tools/dotfiles/utils/expcolors.sh

# Function to print usage information
print_usage() {
  echo "Usage: $0 <target_host> [port]"
  echo ""
  echo "Examples:"
  echo "$0 10.10.11.95"
  echo "$0 10.10.11.95 8080"
  echo ""
  echo "With faketime:"
  echo "faketime \"\$($0 10.10.11.95)\" impacket-getST eighteen.htb/adam.scott:iloveyou1 -impersonate 'enc_dmsa\$' -self -dmsa -debug"
}

# Check for help flag or no arguments
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  print_usage
  exit 0
fi

# Core function definition
getDate() {
  date -d "$(wget --method=HEAD -qSO- --max-redirect=0 $@ 2>&1 | sed -n 's/^ *Date: *//p')" "+%Y-%m-%d %H:%M:%S" 2>/dev/null
}

# Check and install faketime (silent)
check_faketime() {
  if ! command -v faketime &>/dev/null; then
    # Silent installation
    sudo apt update >/dev/null 2>&1 && sudo apt install -y faketime >/dev/null 2>&1

    if [ $? -ne 0 ]; then
      error "Failed to install faketime"
      echo "Please install manually: sudo apt install faketime"
      return 1
    fi
  fi
  return 0
}

# Main execution
main() {
  # Parse arguments
  local target_host="$1"
  local target_port="${2:-80}"

  # Validations
  if [ -z "$target_host" ]; then
    error "No target host specified"
    print_usage
    exit 1
  fi

  # Validate port
  if ! [[ "$target_port" =~ ^[0-9]+$ ]] || [ "$target_port" -lt 1 ] || [ "$target_port" -gt 65535 ]; then
    error "Invalid port number"
    exit 1
  fi

  # Check faketime silently
  if ! check_faketime; then
    exit 1
  fi

  # Get server date - try primary method first
  local server_date=$(getDate "$target_host:$target_port")

  # If primary method failed, try alternatives silently
  if [ -z "$server_date" ]; then
    # Try curl silently
    if command -v curl &>/dev/null; then
      server_date=$(curl -sI "http://$target_host:$target_port/" 2>/dev/null | grep -i "^Date:" | head -1 | sed 's/^Date: *//')
      [ -n "$server_date" ] && server_date=$(date -d "$server_date" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    fi

    # If still empty, try netcat
    if [ -z "$server_date" ] && command -v nc &>/dev/null; then
      local response=$(echo -e "HEAD / HTTP/1.0\r\n\r\n" | timeout 3 nc -w 2 "$target_host" "$target_port" 2>/dev/null)
      server_date=$(echo "$response" | grep -i "^Date:" | head -1 | sed 's/^Date: *//')
      [ -n "$server_date" ] && server_date=$(date -d "$server_date" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    fi
  fi

  # Output result or error
  if [ -n "$server_date" ]; then
    echo "$server_date"
    exit 0
  else
    error "Failed to get date from $target_host:$target_port"
    exit 1
  fi
}

# Run main function with all arguments
main "$@"
