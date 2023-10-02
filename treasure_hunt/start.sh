#!/bin/bash
user_name=''
user_time=0

clear_limit_time=10

STR_COLOR_BACK_YELLOW_START='\033[30;43;1m'
STR_COLOR_END='\033[m'

playing_flug=1

Wait(){
    [ "$2" = '' ] && local waitTime=0.1
    [ "$2" != '' ] && local waitTime=$2
    local count=0
    while [ $count -lt ${#1} ]; do
        local target="${1:$count:1}"
        printf "$target"
        ((count++))
        sleep "$waitTime"
    done
}

input_user_name(){
    echo '> あなたの名前を入力し Enter を押してください'
    read user_name
    if [ -z $user_name ]; then
        user_name='名無し'
    fi
}

show_game_infomation(){
    echo
    Wait "> ${user_name} さん"
    echo
    Wait "> ミッションをすべてクリアし [クマのポーさん] を救出してください"
    echo
    echo
    echo "■ ミッション１"
    Wait "> ポーさんを狙ってるドクロを見つけて削除すること！"
    echo
    echo
    echo "■ ミッション２"
    Wait "> ポーさんを見つけて、今いるこの場所に移動させること！"
    echo
    Wait "ちなみに今いるこの場所はここだよ => "
    pwd
    sleep 1
    echo
    echo "■ ミッション３"
    Wait "> ${clear_limit_time}分以内にゲーム終了すること！"
    echo
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

# ユーザーが正常にゲームプレイ中の状態か判定する
judge_playing

if [ $playing_flug -eq 1 ]; then
    now_time=`date +%s`
    playing_time_sec=$((now_time-user_time))
    playing_time_min=$((playing_time_sec/60))
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
    sh reset.sh
    echo
fi


while read -p "> ゲームを開始しますか? [y/n] " yes_or_no ; do
    case ${yes_or_no} in
        [Yy]|[Yy][Ee][Ss] )
            echo
            break
        ;;

        [Nn]|[Nn][Oo] )
            echo
            Wait '> Bye...!'
            exit
        ;;

        * )
            echo
            echo "> yes か no かでこたえてほしいのです!"
        ;;
    esac
done

# ユーザー名入力
input_user_name
# ユーザー名入力確認
while read -p "> あなたの名前は [${user_name}] でよろしいですか? [y/n] " yes_or_no ; do
    case ${yes_or_no} in
        [Yy]|[Yy][Ee][Ss] )
            echo ""
            break
        ;;

        [Nn]|[Nn][Oo] )
            echo
            input_user_name
        ;;

        * )
            echo
            echo "> yes か no かでこたえてほしいのです!"
        ;;
    esac
done

echo '[ゲーム開始]'
while read -p "> ゲームの説明を聞きますか? [y/n] " yes_or_no ; do
    case ${yes_or_no} in
        [Yy]|[Yy][Ee][Ss] )
            show_game_infomation
            break
        ;;

        [Nn]|[Nn][Oo] )
            echo
            echo '説明をスキップします。'
            break
        ;;

        * )
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
for i in `seq 1 ${num_first_max}`
do
    printf .
    mkdir "START/tobira_${i}"
done

# first
for i in `seq 1 ${num_first_max}`
do
    # second
    for j in `seq 1 ${num_second_max}`
    do
    printf .
        mkdir "START/tobira_${i}/tobira_${i}_${j}"
    done
done


#ドクロ配置
dokuro_dir_num_first=$(($RANDOM % $num_first_max + 1))
dokuro_dir_num_second=$(($RANDOM % $num_second_max + 1))
cp items/dokuro.txt "START/tobira_${dokuro_dir_num_first}/tobira_${dokuro_dir_num_first}_${dokuro_dir_num_second}/hiraite.txt"

#ポーさん配置
pooh_dir_num_first=$(($RANDOM % $num_first_max + 1))
pooh_dir_num_second=$(($RANDOM % $num_second_max + 1))
## ドクロと同じfirstディレクトリにならないように制御
while :
do
    if [ $pooh_dir_num_first -ne $dokuro_dir_num_first ]; then
        break
    fi
    pooh_dir_num_first=$(($RANDOM % $num_first_max + 1))
done
cp items/pooh-wait.txt "START/tobira_${pooh_dir_num_first}/tobira_${pooh_dir_num_first}_${pooh_dir_num_second}/hiraite.txt"

#ポーさんともだち配置
for i in `seq 1 4`
do
    printf .
    pooh_friend_dir_num_first=$(($RANDOM % $num_first_max + 1))
    pooh_friend_dir_num_second=$(($RANDOM % $num_second_max + 1))
    # hiraite.txt（ドクロとポーさん）と重複しないファイル名にする。
    cp "items/pooh-friend-${i}.txt" "START/tobira_${pooh_friend_dir_num_first}/tobira_${pooh_friend_dir_num_first}_${pooh_friend_dir_num_second}/friend-${i}.txt"
    # echo
    # echo "デバッグ"
    # echo "friend-${i}:  ${pooh_friend_dir_num_first}, ${pooh_friend_dir_num_second}"
done

# echo
# echo "デバッグ"
# echo "dokuro : ${dokuro_dir_num_first}, ${dokuro_dir_num_second}"
# echo "pooh : ${pooh_dir_num_first}, ${pooh_dir_num_second}"

echo
echo
Wait '■ ヒント１'
echo
echo -e "> まずは下のコマンドを使って ${STR_COLOR_BACK_YELLOW_START} START ディレクトリに移動 ${STR_COLOR_END} をしてみてね"
echo '========================================'
echo '  | コマンド    |           説明'
echo '========================================'
echo '1 | pwd         | 自分がいる場所を表示'
echo '----------------------------------------'
echo '2 | ls          | 存在するファイルを表示'
echo '----------------------------------------'
echo '3 | cd          | 自分の場所を移動'
echo '----------------------------------------'
echo '4 | cat         | ファイルの中身確認'
echo '----------------------------------------'
echo '5 | mv          | ファイルを移動'
echo '----------------------------------------'
echo '6 | rm          | ファイルを削除'
echo '========================================'
echo
Wait '■ ヒント２'
echo
echo -e "> ミッションが ${STR_COLOR_BACK_YELLOW_START} 終わったら ${STR_COLOR_END} 下のコマンドでゴールだよ！"
echo '========================================'
echo '  | コマンド    |           説明'
echo '========================================'
echo '1 | sh end.sh   | 終了スクリプト実行'
echo '========================================'
echo
echo
Wait '> 最初は、ヒントをよく確認しならがら進めてみよう！'
echo
Wait '> 今から時間をはかるよ、、、よーいスタート！'
echo

echo $user_name > user_name_tmp
printf `date +%s` > user_time_tmp