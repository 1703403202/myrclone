name: CloudSync-Actions

on:
  push:
    branches:
      - master
  schedule:
    - cron: 30 */6 * * *
  watch:
    types: started
    
jobs:
  run-it:
    runs-on: ubuntu-latest
    name: CloudSync-Actions
    steps:
      - name: Checkout master
        uses: actions/checkout@master

      - name: Install rclone
        run: |
          curl https://rclone.org/install.sh | sudo bash

      - name: Read Rclone config from GitHub secret
        env:
          RCLONE_CONFIG: ${{ secrets.CLOUDSYNC_RCLONE_CONFIG }}
        run: |
          mkdir -p ~/.config/rclone
          echo "$RCLONE_CONFIG" > ~/.config/rclone/rclone.conf
          
      - name: Rclone-Run
        run: |
          # Rclone-Run
          # 延迟函数
          delay()
          {
          random_time=$(($RANDOM % $1))
          echo "等待 ${random_time} 分钟后开始同步"
          for((i=1;i<=${random_time};i++));  
          do
          echo "倒计时 $[${random_time}-$i] 分钟"
          sleep 1m
          done
          }
          # 随机延迟0~15分钟后再进行操作,可自行设置时间
          delay 1
          
          # 更改时区
          sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

          # 去重
          rclone dedupe weking.chen@gmail.com:Backup

          rclone sync --user-agent "NONISV|Microsoft|Microsoft OneDrive for Windows/24.055.0317.0002" -v weking_spare:spare weking.chen@gmail.com:Backup/spare --drive-acknowledge-abuse
          rclone sync --user-agent "NONISV|Microsoft|Microsoft OneDrive for Windows/24.055.0317.0002" -v weking_spare:iOS_Photo weking.chen@gmail.com:Backup/iOS_Photo --drive-acknowledge-abuse
          rclone sync --user-agent "NONISV|Microsoft|Microsoft OneDrive for Windows/24.055.0317.0002" -v weking_spare:gphotos weking.chen@gmail.com:Backup/gphotos --drive-acknowledge-abuse
          rclone sync --user-agent "NONISV|Microsoft|Microsoft OneDrive for Windows/24.055.0317.0002" -v weking_spare:bitwarden_backup weking.chen@gmail.com:Backup/bitwarden_backup --drive-acknowledge-abuse
          echo "weking_spare文件已备份到Google盘"
