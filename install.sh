#!/usr/bin/env bash
# install.sh — AI Engineering Skills 一鍵安裝
# Usage:
#   bash install.sh                    # 安裝全部到 .claude/skills/
#   bash install.sh --codex            # 安裝到 .codex/skills/
#   bash install.sh --list             # 列出可安裝的 skill
#   bash install.sh --skill 1 3        # 只裝 Boundary-First + Adversarial Review
#   bash install.sh --target /my/proj  # 指定專案目錄
#   bash install.sh --uninstall        # 移除已安裝的 skill

set -euo pipefail

# --- Config ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="."
AGENT="claude"  # claude or codex

# --- Skill definitions ---
# Format: "id:source_dir:target_name:description"
SKILLS=(
  "0:cw-brainstorming:cw-brainstorming:Brainstorming Capture — 發想捕捉 + Discovery Gate"
  "1:claude-code/boundary-first-multi-repo-engineering:boundary-first-multi-repo-engineering:Boundary-First Engineering — 跨 repo 治理 + UGP 10 Gate"
  "2:executable-spec-planning:executable-spec-planning:Executable Spec Planning — 可執行規格書"
  "3:adversarial-code-review:adversarial-code-review:Adversarial Code Review — 證偽法審查"
  "4:usp-brainstorm:usp-brainstorm:USP Brainstorm — 產品賣點競爭分析"
)

CODEX_SKILLS=(
  "0:cw-brainstorming:cw-brainstorming:Brainstorming Capture"
  "1:codex/boundary-first-multi-repo-engineering:boundary-first-multi-repo-engineering:Boundary-First Engineering"
  "2:executable-spec-planning:executable-spec-planning:Executable Spec Planning"
  "3:adversarial-code-review:adversarial-code-review:Adversarial Code Review"
  "4:usp-brainstorm:usp-brainstorm:USP Brainstorm"
)

# --- Parse args ---
SELECTED_IDS=()
UNINSTALL=false
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex)
      AGENT="codex"
      shift
      ;;
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --skill)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
        SELECTED_IDS+=("$1")
        shift
      done
      ;;
    --uninstall)
      UNINSTALL=true
      shift
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    --help|-h)
      echo "Usage: bash install.sh [options]"
      echo ""
      echo "Options:"
      echo "  --codex            Install to .codex/skills/ (default: .claude/skills/)"
      echo "  --target <dir>     Target project directory (default: current directory)"
      echo "  --skill <id...>    Install specific skills by ID (e.g., --skill 1 3)"
      echo "  --list             List available skills"
      echo "  --uninstall        Remove installed skills"
      echo "  --help             Show this help"
      echo ""
      echo "Examples:"
      echo "  bash install.sh                     # Install all to .claude/skills/"
      echo "  bash install.sh --codex             # Install all to .codex/skills/"
      echo "  bash install.sh --skill 1 3         # Install Boundary-First + Adversarial Review"
      echo "  bash install.sh --target ~/myproj   # Install to specific project"
      exit 0
      ;;
    *)
      echo "Unknown option: $1. Use --help for usage." >&2
      exit 1
      ;;
  esac
done

# --- Select skill set ---
if [[ "$AGENT" == "codex" ]]; then
  SKILL_SET=("${CODEX_SKILLS[@]}")
  INSTALL_DIR="$TARGET_DIR/.codex/skills"
else
  SKILL_SET=("${SKILLS[@]}")
  INSTALL_DIR="$TARGET_DIR/.claude/skills"
fi

# --- List mode ---
if [[ "$LIST_ONLY" == true ]]; then
  echo "Available skills:"
  echo ""
  for entry in "${SKILL_SET[@]}"; do
    IFS=':' read -r id src name desc <<< "$entry"
    echo "  $id  $name"
    echo "     $desc"
    echo ""
  done
  exit 0
fi

# --- Filter by selected IDs ---
if [[ ${#SELECTED_IDS[@]} -gt 0 ]]; then
  FILTERED=()
  for entry in "${SKILL_SET[@]}"; do
    IFS=':' read -r id src name desc <<< "$entry"
    for sel in "${SELECTED_IDS[@]}"; do
      if [[ "$id" == "$sel" ]]; then
        FILTERED+=("$entry")
      fi
    done
  done
  SKILL_SET=("${FILTERED[@]}")
fi

# --- Uninstall mode ---
if [[ "$UNINSTALL" == true ]]; then
  echo "Uninstalling from $INSTALL_DIR ..."
  for entry in "${SKILL_SET[@]}"; do
    IFS=':' read -r id src name desc <<< "$entry"
    if [[ -d "$INSTALL_DIR/$name" ]]; then
      rm -rf "$INSTALL_DIR/$name"
      echo "  ✓ Removed $name"
    else
      echo "  - $name (not installed)"
    fi
  done
  echo "Done."
  exit 0
fi

# --- Install ---
echo "Installing ${#SKILL_SET[@]} skill(s) to $INSTALL_DIR ..."
echo ""

mkdir -p "$INSTALL_DIR"

INSTALLED=0
for entry in "${SKILL_SET[@]}"; do
  IFS=':' read -r id src name desc <<< "$entry"
  SRC_PATH="$SCRIPT_DIR/$src"

  if [[ ! -d "$SRC_PATH" ]]; then
    echo "  ✗ $name — source not found: $src"
    continue
  fi

  # Remove old version if exists
  if [[ -d "$INSTALL_DIR/$name" ]]; then
    rm -rf "$INSTALL_DIR/$name"
  fi

  cp -r "$SRC_PATH" "$INSTALL_DIR/$name"
  echo "  ✓ $name"
  INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Installed $INSTALLED skill(s) to $INSTALL_DIR"

# --- Post-install notes ---
if [[ "$AGENT" == "codex" ]]; then
  echo ""
  echo "Note: Restart Codex to pick up new skills."
elif [[ "$AGENT" == "claude" ]]; then
  echo ""
  echo "Skills are ready. Claude Code will auto-detect them."
fi
