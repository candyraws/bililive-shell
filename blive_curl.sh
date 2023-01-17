#!/bin/bash

blive_room_id=$1
sleep_min=3
ua_setting="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"

blive_api="https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo?room_id=${blive_room_id}&protocol=0&format=0&codec=0&qn=10000"

# 开始前检测是否传入正确的房间号
if [ -z "${blive_room_id}" ]; then
    echo "$(date +%Y%m%d_%H%M%S): (6)检测到传入的room_id为空，已退出"
    exit 6
elif [ "$(echo -n "${blive_room_id}" | grep -o "[[:digit:]]" | wc -l)" != ${#blive_room_id} ]; then
    echo "$(date +%Y%m%d_%H%M%S): (7)检测到room_id ${blive_room_id} 非纯数字，已退出"
    exit 7
fi

while :; do
    blive_api_back=$(curl -s --retry 2 --retry-delay 3 --connect-timeout 10 -A "${ua_setting}" "${blive_api}")
    curl_status_code=$?
    blive_status=$(echo "${blive_api_back}" | jq -r '.data.live_status')
    if [ "${blive_status}" == "1" ]; then
        blive_direct_url=$(echo "${blive_api_back}" | jq -jr '.data.playurl_info.playurl.stream[].format[] | select(.format_name=="flv").codec[]|.url_info[].host,.base_url,.url_info[].extra')
        blive_ttl=$(echo "${blive_api_back}" | jq -r '.data.playurl_info.playurl.stream[].format[] | select(.format_name=="flv").codec[].url_info[].stream_ttl')
        echo "$(date +%Y%m%d_%H%M%S): 直播中，拉起curl，开始录制，预期直播ttl: ${blive_ttl}"
        blive_output_name="$(date +%Y%m%d_%H%M%S)_${blive_room_id}.flv"
        curl -A "${ua_setting}" -e "https://live.bilibili.com/" "${blive_direct_url}" -o "${blive_output_name}"
        curl2_status_code=$?
        if [ "${curl2_status_code}" != "0" ]; then
            echo "$(date +%Y%m%d_%H%M%S): curl2非正常退出，已停止录制，curl2错误码${curl2_status_code}"
            exit 4
        else
            echo "$(date +%Y%m%d_%H%M%S): curl2已自动退出，可能是直播已结束或分段已经达到预期ttl"
			test -s "${blive_output_name}" || rm "${blive_output_name}"
        fi
    elif [ "${blive_status}" == "2" ]; then
        echo -ne "$(date +%Y%m%d_%H%M%S): 正在播放轮播视频，不录制, ${sleep_min}分钟后将再次检测\r"
        sleep "${sleep_min}"m
    elif [ "${blive_status}" == "0" ]; then
        echo -ne "$(date +%Y%m%d_%H%M%S): 未开播, ${sleep_min}分钟后将再次检测\r"
        sleep "${sleep_min}"m
    elif [ ${curl_status_code} != "0" ]; then
        echo "$(date +%Y%m%d_%H%M%S): (3) API获取失败，curl错误码${curl_status_code}"
        exit 3
    elif [ -z "${blive_status}" ]; then
        echo "$(date +%Y%m%d_%H%M%S): (1) 直播间状态码为空，可能是jq或curl未安装"
        exit 1
    elif [ "${blive_status}" == "null" ]; then
        echo "$(date +%Y%m%d_%H%M%S): (5) 直播间状态码检测失败，请检查直播间号 (${blive_room_id}) 是否正确或api是否失效"
        exit 5
    else
        echo "$(date +%Y%m%d_%H%M%S): (2) 直播间状态码: ${blive_status};预期之外的错误"
        exit 2
    fi
done
