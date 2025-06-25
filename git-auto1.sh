#!/bin/bash

# ✅ 指定提交訊息或使用預設（含日期）
if [ -z "$1" ]; then
  commit_msg="$(date '+%Y-%m-%d %H:%M') 自動提交"
else
  commit_msg="$1"
fi

# ✅ 自動加檔案（有修改才進行）
if git diff --quiet && git diff --cached --quiet; then
  echo "✅ 沒有變更可提交，工作目錄乾淨。"
  exit 0
fi

echo "✅ 加入所有變更..."
git add .

echo "✅ 提交訊息：$commit_msg"
git commit -m "$commit_msg"

# ✅ 推送多個分支（預設只推當前分支）
branches=($(git branch --show-current))

for branch in "${branches[@]}"; do
  echo "🚀 準備推送分支：$branch"

  # 檢查是否已設定 upstream
  upstream=$(git rev-parse --symbolic-full-name --verify --quiet "$branch@{u}")
  if [ -z "$upstream" ]; then
    echo "🔧 尚未設定 upstream，正在設定..."
    git push --set-upstream origin "$branch"
  else
    git push origin "$branch"
  fi
done

# ✅ 自動開啟 GitHub 頁面
remote_url=$(git config --get remote.origin.url)
web_url=$(echo "$remote_url" | sed -E 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')

echo "🌐 開啟 GitHub 頁面：$web_url"
cmd.exe /C start "$web_url"

echo "🎉 全部推送完成！"
