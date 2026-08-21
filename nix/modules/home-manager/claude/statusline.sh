#!/bin/bash
set -euo pipefail

input=$(cat)

parsed=$(printf '%s' "$input" | jq -r '
  @sh "MODEL=\(.model.display_name // "?")",
  @sh "DIR=\(.workspace.current_dir // "")",
  @sh "GIT_WT=\(.workspace.git_worktree // "")",
  @sh "WT_NAME=\(.worktree.name // "")",
  @sh "PCT=\(.context_window.used_percentage // 0 | floor)",
  @sh "CTX_SIZE=\(.context_window.context_window_size // 0)",
  @sh "FIVE_H=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "SEVEN_D=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "FAST=\(.fast_mode // false)",
  @sh "EFFORT=\(.effort.level // "")"
') || { echo "parse error" >&2; exit 1; }
eval "$parsed"

C=$'\033[36m'
G=$'\033[32m'
Y=$'\033[33m'
R=$'\033[31m'
D=$'\033[2m'
B=$'\033[1m'
X=$'\033[0m'

OUT="${B}${DIR##*/}${X}"

BRANCH=""
if git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
fi

if [ -n "$GIT_WT" ]; then
  OUT="${OUT} ${D}wt:${X}${C}${GIT_WT}${X}"
elif [ -n "$WT_NAME" ]; then
  OUT="${OUT} ${D}wt:${X}${C}${WT_NAME}${X}"
fi

[ -n "$BRANCH" ] && OUT="${OUT} ${Y}${BRANCH}${X}"

MODEL_LABEL="$MODEL"
[ "$FAST" = "true" ] && MODEL_LABEL="${MODEL_LABEL}/fast"
[ -n "$EFFORT" ] && [ "$EFFORT" != "high" ] && MODEL_LABEL="${MODEL_LABEL}@${EFFORT}"

[ "$PCT" -gt 100 ] && PCT=100
[ "$PCT" -lt 0 ] && PCT=0

if [ "$PCT" -ge 90 ]; then BAR_C="$R"
elif [ "$PCT" -ge 70 ]; then BAR_C="$Y"
else BAR_C="$G"; fi

BAR_W=10
FILLED=$((PCT * BAR_W / 100))
EMPTY=$((BAR_W - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v F "%${FILLED}s" && BAR="${F// /█}"
[ "$EMPTY" -gt 0 ] && printf -v E "%${EMPTY}s" && BAR="${BAR}${E// /░}"

if [ "$CTX_SIZE" -gt 0 ]; then
  CTX_K=$((CTX_SIZE / 1000))k
else
  CTX_K="?"
fi

OUT="${OUT} ${D}|${X} ${C}${MODEL_LABEL}${X} ${BAR_C}${BAR}${X} ${PCT}%/${CTX_K}"

LIMITS=""
if [ -n "$FIVE_H" ]; then
  FH=$(printf '%.0f' "$FIVE_H")
  if [ "$FH" -ge 80 ]; then LIM_C="$R"
  elif [ "$FH" -ge 50 ]; then LIM_C="$Y"
  else LIM_C="$G"; fi
  LIMITS="${D}5h:${X}${LIM_C}${FH}%${X}"
fi
if [ -n "$SEVEN_D" ]; then
  SD=$(printf '%.0f' "$SEVEN_D")
  if [ "$SD" -ge 80 ]; then LIM_C="$R"
  elif [ "$SD" -ge 50 ]; then LIM_C="$Y"
  else LIM_C="$G"; fi
  LIMITS="${LIMITS:+$LIMITS }${D}7d:${X}${LIM_C}${SD}%${X}"
fi

[ -n "$LIMITS" ] && OUT="${OUT} ${D}|${X} ${LIMITS}"

printf '%s\n' "$OUT"
