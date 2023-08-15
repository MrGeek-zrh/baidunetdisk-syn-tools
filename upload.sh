#!/usr/bin/env bash

token="your token"

dest_filename="$(date '+%Y-%m-%dT%H-%M-%S%Z')"
# 这里改成自己的路径
compress_file="/home/mrgeek/${dest_filename}.7z"
wait2upload_dirs="/home/mrgeek/document/"
# 这里改成自己想要上传的文件夹
7z a $compress_file ${wait2upload_dirs}books/ ${wait2upload_dirs}codes/ ${wait2upload_dirs}files-master/ ${wait2upload_dirs}picture/
file_size="$(stat -c %s ${compress_file})"

piece_dir="/home/mrgeek/up_tmp/"
mkdir -p $piece_dir
if [ $file_size -gt 4194304 ]; then
	split -b 4194304 $compress_file $piece_dir
	small_files="$(ls $piece_dir)"
	block_list='['
	for file in $small_files; do
		echo "file:"$piece_dir$file
		md5="$(md5sum $piece_dir$file | cut -d ' ' -f 1)"
		md5_list="\"${md5}\","
		block_list="${block_list}${md5_list}"
	done
	block_list="${block_list}]"
	block_list="$(echo $block_list | sed 's/,]$/]/')"
	
	echo ""
	echo ""
	echo "===============创建上传任务===================="
	# 创建上传任务 
	curl "https://pan.baidu.com/rest/2.0/xpan/file?method=precreate&access_token=${token}" -d "path=/apps/tools/${dest_filename}.7z&size=${file_size}&isdir=0&autoinit=1&rtype=3&block_list=${block_list}" -H "User-Agent: pan.baidu.com" > up-tmp.txt
	upload_id="$(cat up-tmp.txt | jq '.uploadid' | sed -E 's/"(.*)"/\1/')"
	echo "upload-task created successfully. uploadid:${upload_id}"

	# 分片上传
	echo ""
	echo ""
	echo "=============开始分片上传======================="
	pieces_count=$(echo "$small_files" | wc -w)
	echo "一共有$pieces_count个切片"
	num=0		
	for piece in $small_files; do
		echo "第$((num+1))片/共$pieces_count片"
		curl -F "file=@/home/mrgeek/up_tmp/${piece}" "https://d.pcs.baidu.com/rest/2.0/pcs/superfile2?method=upload&access_token=${token}&type=tmpfile&path=/app/tools/${dest_filename}&uploadid=${upload_id}=&partseq=${num}"
		num=$((num+1))
		echo ""
		echo ""
	done
	
	echo ""
	echo ""
	echo ""
	echo "=================合并切片=========================="
	curl "https://pan.baidu.com/rest/2.0/xpan/file?method=create&access_token=${token}" -d "path=/apps/tools/${dest_filename}.7z&size=${file_size}&isdir=0&rtype=3&uploadid=${upload_id}=&block_list=${block_list}" -H "User-Agent: pan.baidu.com"

	rm up-tmp.txt
	rm -rf ${piece_dir}
	rm $compress_file
fi


