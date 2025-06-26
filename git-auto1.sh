#!/bin/bash

# ========= 設定區 =========

# 自訂預設訊息（當沒帶參數時）
default_msg="$(date '+%Y-%m-%d %H:%M') 自動提交"

# ========= 前置檢查 =========

# 檢查是否在 Git 專案中
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "❌ 錯誤：你不在一個 Git 專案目錄中！"
  exit 1
fi

# 確認是否有遠端（origin）
if ! git remote get-url origin > /dev/null 2>&1; then
  echo "❌ 錯誤：尚未設定 Git 遠端 origin，請先設定："
  echo "  git remote add origin <url>"
  exit 1
fi

# ========= 處理提交訊息 =========

if [ -z "$1" ]; then
  commit_msg="$default_msg"
else
  commit_msg="$1"
fi

# ========= 是否有變更 =========

if git diff --quiet && git diff --cached --quiet; then
  echo "✅ 沒有變更可提交，工作目錄乾淨。"
  exit 0
fi

echo "✅ 加入所有變更..."
git add .

echo "✅ 提交訊息：$commit_msg"
git commit -m "$commit_msg" || {
  echo "❌ 提交失敗，請檢查錯誤。"
  exit 1
}

# ========= 推送分支 =========

branch=$(git branch --show-current)
echo "🚀 準備推送分支：$branch"

# 如果沒設 upstream，自動幫你設定
if ! git rev-parse --symbolic-full-name --verify "$branch@{u}" > /dev/null 2>&1; then
  echo "🔧 設定上游分支：origin/$branch"
  git push --set-upstream origin "$branch" || {
    echo "❌ 推送失敗。"
    exit 1
  }
else
  git push origin "$branch" || {
    echo "❌ 推送失敗，請執行 git pull 檢查分歧狀況。"
    exit 1
  }
fi

# ========= 開啟 GitHub 頁面 =========

remote_url=$(git config --get remote.origin.url)
web_url=$(echo "$remote_url" | sed -E 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')

echo "🌐 開啟 GitHub 頁面：$web_url"
cmd.exe /C start "$web_url"

echo "🎉 已完成提交與推送！"
