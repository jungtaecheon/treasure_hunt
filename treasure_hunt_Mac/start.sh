#!/bin/bash
user_name=''
user_time=0

clear_limit_time=10

STR_COLOR_BACK_YELLOW_START='\033[30;43;1m'
STR_COLOR_END='\033[m'

playing_flug=1

Wait() {
    [ "$2" = '' ] && local waitTime=0.1
    [ "$2" != '' ] && local waitTime=$2
    local count=0
    while [ $count -lt ${#1} ]; do
        local target="${1:$count:1}"
        printf "%s" "$target"
        ((count++))
        sleep "$waitTime"
    done
}

input_user_name() {
    echo '> あなたの名前を入力し Enter を押してください'
    read -r user_name
    if [ -z "$user_name" ]; then
        user_name='名無し'
    fi
}

show_game_infomation() {
    echo
    Wait "> ${user_name} さん"
    echo
    Wait "> ミッションをすべてクリアし [クマのポーさん] を救出してください"
    echo
    echo
    echo "■ ミッション１"
    Wait "> ポーさんを狙ってるドクロを見つけて削除すること！（rm コマンド）"
    echo
    echo
    echo "■ ミッション２"
    Wait "> ポーさんを見つけて、今いるこの場所に移動させること！（mv コマンド）"
    echo
    echo
    Wait "ちなみに今いるディレクトリのパス（場所）はここだよ => "
    echo
    pwd
    sleep 1
    echo
    echo "■ ミッション３"
    Wait "> ${clear_limit_time}分以内にゲーム終了すること！"
    echo
}

judge_playing() {
    if ! ls user_name_tmp 1>/dev/null 2>/dev/null; then
        playing_flug=0
    else
        user_name=$(head -n 1 user_name_tmp)
    fi

    if ! ls user_time_tmp 1>/dev/null 2>/dev/null; then
        playing_flug=0
    else
        user_time=$(head -n 1 user_time_tmp)
    fi

    if ! ls START 1>/dev/null 2>/dev/null; then
        playing_flug=0
    fi
}

# ユーザーが正常にゲームプレイ中の状態か判定する
judge_playing

if [ $playing_flug -eq 1 ]; then
    now_time=$(date +%s)
    playing_time_sec=$((now_time - user_time))
    playing_time_min=$((playing_time_sec / 60))
    echo
    cat items/playing-text.txt
    echo
    echo
    echo ">>>>>> ${user_name} さんが、ゲームをプレイ中です！"
    echo ">>>>>> ${playing_time_sec} 秒 (${playing_time_min} 分) 経過中..."
    echo
    echo
    echo
    echo '■ ヒント'
    echo "> 下のコマンドで、プレイ中のゲームを終了できるよ"
    echo '========================================'
    echo '  | コマンド    |           説明'
    echo '========================================'
    echo '1 | sh end.sh   | 終了スクリプト実行'
    echo '----------------------------------------'
    echo '2 | sh reset.sh | リセットスクリプト実行'
    echo '========================================'

    exit
else
    # 不要ファイル削除し、ゲームを開始する
    sh reset.sh auto_exec
    echo
fi

while read -r -p "> ゲームを開始しますか? [y/n] " yes_or_no; do
    case ${yes_or_no} in
    [Yy] | [Yy][Ee][Ss])
        echo
        break
        ;;

    [Nn] | [Nn][Oo])
        echo
        Wait '> Bye...!'
        exit
        ;;

    *)
        echo
        echo "> yes か no かでこたえてほしいのです!"
        ;;
    esac
done

# ユーザー名入力
input_user_name
# ユーザー名入力確認
while read -r -p "> あなたの名前は [${user_name}] でよろしいですか? [y/n] " yes_or_no; do
    case ${yes_or_no} in
    [Yy] | [Yy][Ee][Ss])
        echo ""
        break
        ;;

    [Nn] | [Nn][Oo])
        echo
        input_user_name
        ;;

    *)
        echo
        echo "> yes か no かでこたえてほしいのです!"
        ;;
    esac
done

echo '[ゲーム開始]'
while read -r -p "> ゲームの説明を聞きますか? [y/n] " yes_or_no; do
    case ${yes_or_no} in
    [Yy] | [Yy][Ee][Ss])
        show_game_infomation
        break
        ;;

    [Nn] | [Nn][Oo])
        echo
        echo '説明をスキップします。'
        break
        ;;

    *)
        echo
        echo "> yes か no かでこたえてほしいのです!"
        ;;
    esac
done
echo
echo '[ファイルを生成中]'

printf .
mkdir START

num_first_max=5
num_second_max=5

# first
for i in $(seq 1 ${num_first_max}); do
    printf .
    mkdir "START/tobira_${i}"
done

# first
for i in $(seq 1 ${num_first_max}); do
    # second
    for j in $(seq 1 ${num_second_max}); do
        printf .
        mkdir "START/tobira_${i}/tobira_${i}_${j}"
    done
done

#ドクロ配置
dokuro_dir_num_first=$((RANDOM % num_first_max + 1))
dokuro_dir_num_second=$((RANDOM % num_second_max + 1))
cp items/dokuro.txt "START/tobira_${dokuro_dir_num_first}/tobira_${dokuro_dir_num_first}_${dokuro_dir_num_second}/hiraite.txt"

#ポーさん配置
pooh_dir_num_first=$((RANDOM % num_first_max + 1))
pooh_dir_num_second=$((RANDOM % num_second_max + 1))
## ドクロと同じfirstディレクトリにならないように制御
while :; do
    if [ $pooh_dir_num_first -ne $dokuro_dir_num_first ]; then
        break
    fi
    pooh_dir_num_first=$((RANDOM % num_first_max + 1))
done
cp items/pooh-wait.txt "START/tobira_${pooh_dir_num_first}/tobira_${pooh_dir_num_first}_${pooh_dir_num_second}/hiraite.txt"

# echo
# echo "デバッグ"
# echo "dokuro : ${dokuro_dir_num_first}, ${dokuro_dir_num_second}"
# echo "pooh : ${pooh_dir_num_first}, ${pooh_dir_num_second}"

#ポーさんともだち配置
for i in $(seq 1 4); do
    printf .
    pooh_friend_dir_num_first=$((RANDOM % num_first_max + 1))
    pooh_friend_dir_num_second=$((RANDOM % num_second_max + 1))
    while :; do
        ls START/tobira_${pooh_friend_dir_num_first}/tobira_${pooh_friend_dir_num_first}_${pooh_friend_dir_num_second} | grep hiraite.txt >/dev/null
        if [ $? -ne 0 ]; then
            break
        fi

        # echo
        # echo "デバッグ"
        # echo "重複を検知しました"
        # echo "friend-${i}:  ${pooh_friend_dir_num_first}, ${pooh_friend_dir_num_second}"

        # もし既に同じディレクトリ内に hiraite.txt が存在する場合、ランダムな数字でディレクトリを出し直す
        pooh_friend_dir_num_first=$((RANDOM % num_first_max + 1))
        pooh_friend_dir_num_second=$((RANDOM % num_second_max + 1))
    done

    cp "items/pooh-friend-${i}.txt" "START/tobira_${pooh_friend_dir_num_first}/tobira_${pooh_friend_dir_num_first}_${pooh_friend_dir_num_second}/hiraite.txt"

    # echo
    # echo "デバッグ"
    # echo "friend-${i}:  ${pooh_friend_dir_num_first}, ${pooh_friend_dir_num_second}"
done

echo
echo
Wait '■ 進め方１'
echo
echo "> ${STR_COLOR_BACK_YELLOW_START} まず最初は「START」ディレクトリに移動 ${STR_COLOR_END} してね"
echo '========================================'
echo '  | コマンド    |           説明'
echo '========================================'
echo '1 | pwd         | 現在のディレクトリのパス（場所）を表示'
echo '----------------------------------------'
echo '2 | ls          | 存在するファイルを表示'
echo '----------------------------------------'
echo '3 | cd          | ディレクトリに移動'
echo '----------------------------------------'
echo '4 | cat         | ファイルの中身を出力'
echo '----------------------------------------'
echo '5 | mv          | ファイルを移動'
echo '----------------------------------------'
echo '6 | rm          | ファイルを削除'
echo '========================================'
echo
Wait '■ 進め方２'
echo
echo "> ミッションが${STR_COLOR_BACK_YELLOW_START} 終わったら下のコマンドでゴール ${STR_COLOR_END}だよ！"
echo '========================================'
echo '  | コマンド    |           説明'
echo '========================================'
echo '1 | sh end.sh   | 終了スクリプト実行'
echo '========================================'
echo
echo
Wait '> 最初は、進め方をよく確認しならがら進めてみよう！'
echo
Wait '> 今から時間をはかるよ、、、よーいスタート！'
echo

printf "%s" "$user_name" >user_name_tmp
printf "%s" "$(date +%s)" >user_time_tmp
