#!/usr/bin/env sh

LIBS=()

WINDIR=$(cygpath -u -W)

shopt -s nocasematch
function addToLibs() {
  local TARGET=${1} && shift
  if [[ "$(which "${TARGET}")" == "${WINDIR}"* ]]; then
    :
  else
    for lib in ${LIBS[@]}; do
      if [[ "${lib}" == "${TARGET}" ]]; then
        return
      fi
    done
    echo $TARGET
  fi
}

RECURSE_INDEX=0

function getLibsForBinary() {
  local TARGET=$1 && shift

  local -i count=0
  for binLib in $(objdump -p "$(cygpath -u "${TARGET}")" | grep "DLL Name:"| sed -e 's/^\s*DLL\sName:\s*//'); do
    if [[ ! -z "$(addToLibs ${binLib})" ]]; then
      echo "added ${binLib}"
      count=$count+1
      LIBS+=("${binLib}")
    fi
  done

  if [[ count -gt 0 ]]; then
    local CURRENT_INDEX=${RECURSE_INDEX}
    RECURSE_INDEX=${#LIBS[@]}
    # recurse if any added from last checked
    echo "recurse check after ${count} added"
    for lib in ${LIBS[@]:${CURRENT_INDEX}}; do
      getLibsForBinary "$(which "${lib}")"
    done
  fi
}

function copyLibs() {
  local TARGET=$1 && shift
  local TARGET_PATH=$(cygpath -u "${TARGET}")
  for lib in ${LIBS[@]}; do
    echo "copy ${lib} to destination"
    cp "$(which "${lib}")" "${TARGET_PATH}"
  done
}

getLibsForBinary "./build/Release/canvas.node"
copyLibs "./build/Release"
