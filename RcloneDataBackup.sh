#!/bin/bash

if [ ! -d "/root/RcloneDataBackup/data" ]; then
    mkdir -p $zip_target
fi

pwd_path="/root/RcloneDataBackup"
zip_target="/root/RcloneDataBackup/data"
data_dir="/www/wwwroot"
local_ip=$(ip a | grep " $(route | grep default | awk 'NR==1{print $NF}'):" -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/')
echo "开始执行数据备份任务，本机信息：$HOSTNAME，$local_ip ..."

# echo "将 $data_dir 目录下文件压缩存放到路径 $zip_target 中..."

# 检查输出文件夹是否存在，不存在则创建
if [ ! -d $zip_target ]; then
    mkdir -p $zip_target
fi

# 遍历数据文件夹并挨个压缩
for file in $(ls $data_dir); do
    # 如果目标文件夹不存在，则创建
    if [ ! -d $zip_target"/"$file ]; then
        mkdir $zip_target"/"$file
    fi
    # 压缩文件
    cd $data_dir
    tar zcvf $zip_target"/"$file"/backup_"$(date +"%Y%m%d%H%M").tar.gz $file
    cd "/root/RcloneDataBackup"
done

# 获取本机IP
local_ip=$(ip a | grep " $(route | grep default | awk 'NR==1{print $NF}'):" -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/')

echo "数据压缩成功，即将开始远程备份..."

# 通过rclone保存至onedrive
/usr/bin/rclone move $zip_target "od-backup:/Servers/$local_ip-$HOSTNAME" -P --delete-empty-src-dirs

echo "数据备份成功：" $(date +"%Y-%m-%d %H:%M:%S") "，备份文件已删除..."

echo "全部任务执行完毕。"
