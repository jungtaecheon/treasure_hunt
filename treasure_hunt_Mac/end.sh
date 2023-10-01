#!/bin/bash

clear_flug=1
playing_flug=1

clear_limit_time=10

user_name=''
user_time=0

now_date=`date '+%Y-%m-%d %H:%M:%S'`

playing_time_sec=0
playing_time_min=0

message_1=''
message_2=''
message_3=''

Wait(){
    [ "$2" = '' ] && local waitTime=0.3
    [ "$2" != '' ] && local waitTime=$2
    local count=0
    while [ $count -lt ${#1} ]; do
        local target="${1:$count:1}"
        /bin/echo -n "$target"
        ((count++))
        sleep "$waitTime"
    done
}

judge_playing(){
    ls | grep user_name_tmp >/dev/null
    if [ $? -ne 0 ]; then
        playing_flug=0
    else
        user_name=`head -n 1 user_name_tmp`
    fi

    ls | grep user_time_tmp >/dev/null
    if [ $? -ne 0 ]; then
        playing_flug=0
    else
        user_time=`head -n 1 user_time_tmp`
    fi

    ls | grep START >/dev/null
    if [ $? -ne 0 ]; then
        playing_flug=0
    fi
}

calc_playing_time(){
    now_time=`date +%s`
    playing_time_sec=$((now_time-user_time))
    playing_time_min=$((playing_time_sec/60))
}

judge_clear(){
    # STARTディレクトリにdokuroが残ってるか
    grep 'dokuro' -rl ./START 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
        message_1='ドクロを削除しました > 成功!'
    else
        clear_flug=0
        message_1='ドクロを削除していません > 失敗'
    fi

    # ポーさんを移動できたか
    grep 'pooh' hiraite.txt 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
        clear_flug=0
        message_2='ポーさんを移動していません > 失敗'
    else
        message_2='ポーさんを移動しました > 成功!'
    fi

    # 制限時間内にクリアしたか
    if [ $playing_time_min -gt $clear_limit_time ]; then
        clear_flug=0
        message_3="${clear_limit_time}分以内にゲームを終了していません > 失敗"
    else
        message_3="${clear_limit_time}分以内にゲームを終了しました > 成功!"
    fi

    # 記録
    ls ./record.txt 1>/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
        touch ./record.txt
    fi
    /bin/echo "=================================" >> ./record.txt
    /bin/echo "日付 : $now_date" >> ./record.txt
    /bin/echo "---------------------------------" >> ./record.txt
    /bin/echo "なまえ : $user_name" >> ./record.txt
    /bin/echo "---------------------------------" >> ./record.txt
    /bin/echo "かかった時間 : ${playing_time_sec} 秒 (${playing_time_min} 分)" >> ./record.txt
    /bin/echo "---------------------------------" >> ./record.txt
    if [ $clear_flug -eq 1 ]; then
        /bin/echo "ミッション : 成功！" >> ./record.txt
    else
        /bin/echo "ミッション : 失敗" >> ./record.txt
    fi
    /bin/echo "=================================" >> ./record.txt
}



judge_playing
# 正常にプレイ中状態じゃない場合は、reset処理を実行
if [ $playing_flug -ne 1 ]; then
    /bin/echo
    /bin/echo "[終了スクリプト失敗]"
    /bin/echo "----------------------------------------"
    /bin/echo "ゲームが正常に開始されてないです"
    /bin/echo "> ゲームをプレイしてから実行してね！"
    /bin/echo "----------------------------------------"
    /bin/echo
    /bin/echo
    /bin/echo '■ ヒント'
    /bin/echo "> 下のコマンドで新しくゲームをプレイできるよ"
    /bin/echo '========================================'
    /bin/echo ' sh start.sh'
    /bin/echo '========================================'

    exit
fi

/bin/echo
/bin/echo '********************************'
/bin/echo
/bin/echo '            ジャッジ'
/bin/echo
/bin/echo '********************************'
Wait "> ${user_name} さん、判定を始めます"

calc_playing_time
judge_clear
sh reset.sh 1>/dev/null 2>/dev/null

/bin/echo
/bin/echo
/bin/echo "■ ミッション１"
Wait "> ... ${message_1}"
/bin/echo
/bin/echo
/bin/echo "■ ミッション２"
Wait "> ... ${message_2}"
/bin/echo
/bin/echo
/bin/echo "■ ミッション３"
Wait "> ... ${message_3}"
/bin/echo
/bin/echo
/bin/echo "■ かかった時間"
Wait "> ... ${playing_time_sec} 秒 (${playing_time_min} 分)"
/bin/echo
/bin/echo

if [ $clear_flug -eq 1 ]; then
    cat items/pooh-clear-1.txt
    sleep 1
    cat items/pooh-clear-2.txt
    sleep 1
    /bin/echo
    /bin/echo
    cat items/success-text.txt
    sleep 1
    /bin/echo
else
    cat items/boom.txt
    sleep 1
    /bin/echo
    /bin/echo
    cat items/pooh-angry.txt
    sleep 1
    /bin/echo
    /bin/echo
    cat items/fail-text.txt
    sleep 1
    /bin/echo
fi

/bin/echo
/bin/echo
/bin/echo
/bin/echo '■ ヒント'
/bin/echo "> 下のコマンドで記録を確認できるよ"
/bin/echo '========================================'
/bin/echo ' cat record.txt'
/bin/echo '========================================'