#!/bin/bash

# Argus GitHub Labels 初始化腳本
# 執行前請確認已安裝 GitHub CLI 並登入：gh auth login
#
# 使用方式：
#   bash .github/create-labels.sh

set -e

REPO="healthy8701/argus_project_test"

echo "=== Argus Label 初始化開始 ==="
echo ""

# ──────────────────────────────────────────
# Step 1：Migration — 將舊 label 的 issue 補貼新 label
# ──────────────────────────────────────────
echo "Step 1：Migration 舊 label → 新 label"

echo "  補貼 'bug' → 'type: bug'..."
gh issue list --repo "$REPO" --label "bug" --state all --limit 500 --json number \
  | jq -r '.[].number' \
  | while read -r num; do
      gh issue edit "$num" --repo "$REPO" --add-label "type: bug" 2>/dev/null || true
    done

echo "  補貼 'enhancement' → 'type: feature'..."
gh issue list --repo "$REPO" --label "enhancement" --state all --limit 500 --json number \
  | jq -r '.[].number' \
  | while read -r num; do
      gh issue edit "$num" --repo "$REPO" --add-label "type: feature" 2>/dev/null || true
    done

echo ""

# ──────────────────────────────────────────
# Step 2：建立新 label（若已存在則跳過）
# ──────────────────────────────────────────
create_label() {
  local name="$1"
  local color="$2"
  local description="$3"

  if gh label list --repo "$REPO" --json name | jq -r '.[].name' | grep -qx "$name"; then
    echo "  [skip] $name 已存在"
  else
    gh label create "$name" --repo "$REPO" --color "$color" --description "$description"
    echo "  [ok]   $name"
  fi
}

echo "Step 2：建立 type: 系列 label"
create_label "type: bug"       "d93f0b" "BUG 回報"
create_label "type: feature"   "0075ca" "新功能需求"
create_label "type: task"      "5319e7" "開發任務（重構、CI/CD 等）"
create_label "type: tech-debt" "e4e669" "技術債"
create_label "type: docs"      "0052cc" "文件相關"
echo ""

echo "Step 3：建立 priority: 系列 label"
create_label "priority: critical" "b60205" "緊急，影響核心功能"
create_label "priority: high"     "e11d48" "高優先，應盡快處理"
create_label "priority: medium"   "f97316" "中優先"
create_label "priority: low"      "fde68a" "低優先，有空再處理"
echo ""

echo "Step 4：建立 page: 系列 label"
create_label "page: login"      "e6b8a2" "登入頁"
create_label "page: home"       "e6b8a2" "主頁"
create_label "page: playback"   "e6b8a2" "回放頁"
create_label "page: control"    "e6b8a2" "控制頁"
create_label "page: events"     "e6b8a2" "事件頁"
create_label "page: status"     "e6b8a2" "狀態頁"
create_label "page: settings"   "e6b8a2" "設定頁"
create_label "page: add-device" "e6b8a2" "新增設備頁"
echo ""

# ──────────────────────────────────────────
# Step 5：刪除已被取代的舊 label
# ──────────────────────────────────────────
delete_label() {
  local name="$1"
  if gh label list --repo "$REPO" --json name | jq -r '.[].name' | grep -qx "$name"; then
    gh label delete "$name" --repo "$REPO" --yes
    echo "  [deleted] $name"
  else
    echo "  [skip]    $name 不存在"
  fi
}

echo "Step 5：刪除已被取代的舊 label"
delete_label "bug"
delete_label "enhancement"
delete_label "documentation"
delete_label "good first issue"
delete_label "help wanted"
delete_label "duplicate"
delete_label "invalid"
delete_label "question"
delete_label "wontfix"
echo ""

echo "=== 完成！==="
echo ""
echo "請前往 https://github.com/$REPO/labels 確認結果"
