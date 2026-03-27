# GitHub 專案管理環境設定指南

本文件說明無法用檔案管理的 GitHub 設定項目，包含 Milestones 和 GitHub Projects。

---

## Labels 初始化

Labels 腳本需要手動執行一次：

```bash
# 確認已安裝 GitHub CLI 並登入
gh auth login --scopes repo,read:project

# 執行初始化腳本
bash .github/create-labels.sh
```

腳本會自動：
1. 將現有 `bug` issue 補貼 `type: bug`
2. 將現有 `enhancement` issue 補貼 `type: feature`
3. 刪除舊的預設 label
4. 建立完整的新 label 系統

---

## Milestones 建立

Milestones 對應 App 版本號，每次規劃新版本時執行以下指令：

```bash
# 建立版本 milestone（調整 title 和 due_on）
gh api repos/Delos-Matrix/Argus/milestones \
  --method POST \
  -f title="v1.1.0" \
  -f description="版本說明" \
  -f due_on="2026-05-31T00:00:00Z"
```

使用規則：
- 每個 issue 建立時指定對應的 milestone
- milestone 完成率 = 該版本 issue 關閉數 / 總數
- 版本發布後將 milestone 狀態設為 closed

---

## GitHub Projects — Project 5「Argus」

Project 5 是主力開發看板，以下說明建議的欄位設定。

### Status 欄位建議選項

| 選項 | 說明 | 對應 label |
|------|------|-----------|
| 📋 Backlog | 已記錄但尚未排入開發 | — |
| 🔨 In Progress | 正在開發中 | `status: in-progress` |
| 👀 In Review | PR 已開，等待 Code Review | `status: needs-review` |
| 🚫 Blocked | 被外部因素阻塞 | `status: blocked` |
| ✅ Done | 已完成並合併 | — |

### Priority 欄位建議選項

| 選項 | 說明 | 對應 label |
|------|------|-----------|
| 🔴 Critical | 緊急，影響核心功能 | `priority: critical` |
| 🟠 High | 高優先，應盡快處理 | `priority: high` |
| 🟡 Medium | 中優先 | `priority: medium` |
| 🟢 Low | 低優先，有空再處理 | `priority: low` |

### 在 GitHub UI 調整欄位選項

1. 前往 [Project 5](https://github.com/orgs/Delos-Matrix/projects/5)
2. 點右上角 `...` → `Settings`
3. 在左側選 `Status` 或 `Priority` 欄位
4. 新增 / 修改選項名稱與顏色

---

## 開發流程總結

```
1. 建立 Issue（選擇對應模板）
   └─ 指定 Milestone（版本號）
   └─ 在 Project 5 設定 Priority
   └─ 貼上對應 label

2. 開始開發
   └─ 在 Project 5 將 Status 改為 In Progress
   └─ Issue 補貼 status: in-progress

3. 開 PR
   └─ 填寫 PR Template（含 Closes #issue號）
   └─ 在 Project 5 將 Status 改為 In Review

4. 合併後
   └─ Issue 自動關閉
   └─ Milestone 進度自動更新
```
