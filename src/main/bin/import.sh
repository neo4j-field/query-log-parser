#!/bin/bash

# Executes all .cypher and .cyp files in alphabetic, ascending order (A-Z) using the cypher-shell from Neo4j.
# See the Usage message for more details.
#
# If executed on a remote server, one way of disconnecting the command from the login-shell is:
# mkdir logs
# screen
## make sure to provide the password via -p or --password
# nohup ./import.sh (with your params) > logs/import.log 2>&1 &

NEO4J_PATH=
CYPHER_SHELL=
IMPORT_PATH=
NEO4J_USER=
NEO4J_PASS=
DATE=

# absolute path where this script is saved; without trailing slash
SCRIPT_PATH=$(
  cd "$(dirname "$0")" || exit
  pwd
)

function printUsageAndExit() {
  echo "Usage: $0 "
  echo "  -n | --neo4j-path"
  echo "    the path to the Neo4j instance from where the cypher-shell is used"
  echo
  echo "  -i | --import-path"
  echo "    the path to the Cypher files for the import"
  echo "    if it is not specified, '../cypher' (relative to the script path) is used"
  echo
  echo "  -u | --user"
  echo "    the Neo4j username used for authentication"
  echo
  echo "  -p | --password"
  echo "    the Neo4j password used for authentication"
  echo "    optional, will be prompted if not specified via the parameters"

  exit 1
}

function import() {
  printf -v DATE '%(%Y-%m-%dT%H:%M:%S%z)T' -1

  echo "${DATE} [INFO] Started import"
  for file in $(/bin/ls "${IMPORT_PATH}" | sort); do
    local filename
    local extension
    filename=$(basename -- "${file}")
    extension="${filename##*.}"

    printf -v DATE '%(%Y-%m-%dT%H:%M:%S%z)T' -1

    if [[ "cypher" == "${extension}" ]] || [[ "cyp" == "${extension}" ]]; then
      echo
      echo "### ${DATE} [INFO] Executing file='${file}'"
      "${CYPHER_SHELL}" <"${IMPORT_PATH}/${file}" -u "${NEO4J_USER}" -p "${NEO4J_PASS}"
    else
      echo "Skipping file='${file}'. Only .cypher and .cyp files are supported."
    fi
  done

  echo
  printf -v DATE '%(%Y-%m-%dT%H:%M:%S%z)T' -1
  echo "${DATE} [INFO] Finished import"
}

function setCypherShell() {
  CYPHER_SHELL="${NEO4J_PATH}/bin/cypher-shell"

  if [[ ! -f "${CYPHER_SHELL}" ]]; then
    echo "Could not find the file='${CYPHER_SHELL}'; will check for .bat file (Windows)"
    CYPHER_SHELL="${CYPHER_SHELL}.bat"
  fi
}

function readParams() {
  POSITIONAL=()
  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -n | --neo4j-path)
      NEO4J_PATH="$2"
      setCypherShell
      shift
      shift
      ;;
    -i | --import-path)
      IMPORT_PATH="$2"
      shift
      shift
      ;;
    -u | --user)
      NEO4J_USER="$2"
      shift
      shift
      ;;
    -p | --password)
      NEO4J_PASS="$2"
      shift
      shift
      ;;
    *) # unknown option
      POSITIONAL+=("$1")
      shift
      ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # restore positional parameters

  [[ -n "${IMPORT_PATH}" ]] || IMPORT_PATH="${SCRIPT_PATH}"/../cypher

  if [[ -z "${NEO4J_PATH}" ]] || [[ -z "${IMPORT_PATH}" ]] || [[ -z "${NEO4J_USER}" ]]; then
    printUsageAndExit
  fi

  if [[ -z "${NEO4J_PASS}" ]]; then
    echo "Please provide the password for authenticating the user '${NEO4J_USER}'."
    read -s -r -p "Password: " NEO4J_PASS
    echo
  fi

  if [[ -z "${NEO4J_PASS}" ]]; then
    echo "No password provided. Aborting."
    exit 1
  fi
}

function main() {
  readParams "$@"

  import
}

main "$@"
