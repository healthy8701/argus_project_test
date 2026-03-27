# GitHub 專案管理環境設定指南

本文件說明所有需要手動操作的 GitHub 設定項目。

---

## 1. GitHub Actions 設定（必須先做）

Workflow 需要一個有 `project` 權限的 Personal Access Token（PAT）才能自動操作 Project。

### 建立 PAT

1. 前往 GitHub → 右上角頭像 → **Settings**
2. 左側選 **Developer settings** → **Personal access tokens** → **Fine-grained tokens**
3. 點 **Generate new token**，設定：
   - **Token name**：`Argus Project Automation`
   - **Expiration**：依需求設定（建議 1 年）
   - **Repository access**：選 `healthy8701/argus_project_test`
   - **Permissions**：
     - Repository → `Issues`: Read and write
     - User → `Projects`: Read and write
4. 複製產生的 token

### 將 PAT 存為 Secret

```bash
gh secret set PROJECT_TOKEN --repo healthy8701/argus_project_test
# 貼上剛才複製的 token，按 Enter
```

---

## 2. Labels 初始化

執行一次即可，重複執行安全（已存在的 label 會跳過）：

```bash
bash .github/create-labels.sh
```

腳本會自動：
1. 將現有 `bug` issue 補貼 `type: bug`
2. 將現有 `enhancement` issue 補貼 `type: feature`
3. 刪除舊的預設 label
4. 建立完整的新 label 系統

---

## 3. GitHub Project

目前使用：[Project 2「argus_test」](https://github.com/users/healthy8701/projects/2)

已設定完成，Status / Priority 欄位皆已建立。如需重建或查詢 ID：

```bash
gh api graphql -f query='{ user(login: "healthy8701") { projectsV2(first: 10) { nodes { id number title fields(first: 20) { nodes { ... on ProjectV2SingleSelectField { id name options { id name } } } } } } } }'
```

---

## 4. Milestones 建立

每次規劃新版本時執行：

```bash
gh api repos/healthy8701/argus_project_test/milestones \
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

## 5. 開發流程總結

```
1. 建立 Issue（選擇對應模板）
   └─ Actions 自動：加入 Project、Status = Backlog、貼 page label
   └─ 手動：指定 Milestone、設定 Priority（若 feature-request 已自動貼 priority label 則跳過）

2. 開始開發
   └─ 在 Project 將 Status 改為 In Progress

3. 開 PR
   └─ 填寫 PR Template（含 Closes #issue號）
   └─ 在 Project 將 Status 改為 In Review

4. 合併後
   └─ Issue 自動關閉
   └─ Milestone 進度自動更新
   └─ 在 Project 將 Status 改為 Done
```

---

## Status / Priority 欄位說明

### Status

| 選項 | 說明 |
|------|------|
| Backlog | 已記錄，尚未排入開發（issue 建立時自動設定） |
| In Progress | 正在開發中 |
| In Review | PR 已開，等待 Code Review |
| Blocked | 被外部因素阻塞 |
| Done | 已完成並合併 |

### Priority

| 選項 | 說明 | 對應 label |
|------|------|-----------|
| Critical | 緊急，影響核心功能 | `priority: critical` |
| High | 高優先，應盡快處理 | `priority: high` |
| Medium | 中優先（預設值） | `priority: medium` |
| Low | 低優先，有空再處理 | `priority: low` |
