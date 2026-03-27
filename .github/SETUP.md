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

## 3. 建立新 Project「Argus (New)」

### Step 1：建立 Project

```bash
gh project create --owner Delos-Matrix --title "Argus (New)"
```

記下輸出的 Project 編號（例如 `6`），後續步驟會用到。

### Step 2：建立 Status 欄位

```bash
gh project field-create <PROJECT_NUMBER> \
  --owner Delos-Matrix \
  --name "Status" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Backlog,In Progress,In Review,Blocked,Done"
```

### Step 3：建立 Priority 欄位

```bash
gh project field-create <PROJECT_NUMBER> \
  --owner Delos-Matrix \
  --name "Priority" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "Critical,High,Medium,Low"
```

### Step 4：更新 Workflow 的 Project ID

建立完成後，執行以下指令取得新 Project 的 Node ID：

```bash
gh project list --owner Delos-Matrix --format json \
  | jq '.projects[] | select(.title == "Argus (New)") | {number, id}'
```

將輸出的 `id` 更新到 `.github/workflows/issue-automation.yml` 的以下位置：

```yaml
const projectId = 'PVT_xxxx';  # 改為新 Project 的 ID
```

同時更新 Status 和 Priority 的 field ID（用以下指令查詢）：

```bash
gh api graphql -f query='
{
  node(id: "<NEW_PROJECT_ID>") {
    ... on ProjectV2 {
      fields(first: 20) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
          }
        }
      }
    }
  }
}'
```

### Step 5：封存舊 Project 5

確認新 Project 運作正常後，封存舊的 Project 5：

1. 前往 [Project 5](https://github.com/orgs/Delos-Matrix/projects/5)
2. 點右上角 `...` → **Close project**

### Step 6：改名新 Project

封存完成後，將「Argus (New)」改名為「Argus」：

```bash
gh project edit <PROJECT_NUMBER> --owner Delos-Matrix --title "Argus"
```

---

## 4. Milestones 建立

每次規劃新版本時執行：

```bash
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

## 5. 開發流程總結

```
1. 建立 Issue（選擇對應模板）
   └─ Actions 自動：加入 Project、Status = Backlog、貼 page label、貼 priority label（bug / feature）
   └─ 手動：指定 Milestone

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
