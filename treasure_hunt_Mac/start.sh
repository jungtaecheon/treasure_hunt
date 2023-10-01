#!/bin/bash
user_name=''
user_time=0

clear_limit_time=10

playing_flug=1

Wait(){
    [ "$2" = '' ] && local waitTime=0.1
    [ "$2" != '' ] && local waitTime=$2
    local count=0
    while [ $count -lt ${#1} ]; do
        local target="${1:$count:1}"
        /bin/echo -n "$target"
        ((count++))
        sleep "$waitTime"
    done
}

input_user_name(){
    /bin/echo '> あなたの名前を入力し Enter を押してください'
    read user_name
    if [ -z $user_name ]; then
        user_name='名無し'
    fi
}

show_game_infomation(){
    /bin/echo
    Wait "> ${user_name} さん"
    /bin/echo
    Wait "> ミッションをすべてクリアし [クマのポーさん] を救出してください"
    /bin/echo
    /bin/echo
    /bin/echo "■ ミッション１"
    Wait "> ポーさんを狙ってるドクロを見つけて削除すること！"
    /bin/echo
    /bin/echo
    /bin/echo "■ ミッション２"
    Wait "> ポーさんを見つけて、今いるこの場所に移動させること！"
    /bin/echo
    Wait "ちなみに今いるこの場所はここだよ => "
    pwd
    sleep 1
    /bin/echo
    /bin/echo "■ ミッション３"
    Wait "> ${clear_limit_time}分以内にゲーム終了すること！"
    /bin/echo
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
    /bin/echo
    cat items/playing-text.txt
    /bin/echo
    /bin/echo
    /bin/echo ">>>>>> ${user_name} さんが、ゲームをプレイ中です！"
    /bin/echo ">>>>>> ${playing_time_sec} 秒 (${playing_time_min} 分) 経過中..."
    /bin/echo
    /bin/echo
    /bin/echo
    /bin/echo '■ ヒント'
    /bin/echo "> 下のコマンドで、プレイ中のゲームを終了できるよ"
    /bin/echo '========================================'
    /bin/echo '  | コマンド    |           説明'
    /bin/echo '========================================'
    /bin/echo '1 | sh end.sh   | 終了スクリプト実行'
    /bin/echo '----------------------------------------'
    /bin/echo '2 | sh reset.sh | リセットスクリプト実行'
    /bin/echo '========================================'

    exit
else
    # 不要ファイル削除し、ゲームを開始する
    sh reset.sh
    /bin/echo
fi


while read -p "> ゲームを開始しますか? [y/n] " yes_or_no ; do
    case ${yes_or_no} in
        [Yy]|[Yy][Ee][Ss] )
            /bin/echo
            break
        ;;

        [Nn]|[Nn][Oo] )
            /bin/echo
            Wait '> Bye...!'
            exit
        ;;

        * )
            /bin/echo
            /bin/echo "> yes か no かでこたえてほしいのです!"
        ;;
    esac
done

# ユーザー名入力
input_user_name
# ユーザー名入力確認
while read -p "> あなたの名前は [${user_name}] でよろしいですか? [y/n] " yes_or_no ; do
    case ${yes_or_no} in
        [Yy]|[Yy][Ee][Ss] )
            /bin/echo ""
            break
        ;;

        [Nn]|[Nn][Oo] )
            /bin/echo
            input_user_name
        ;;

        * )
            /bin/echo
            /bin/echo "> yes か no かでこたえてほしいのです!"
        ;;
    esac
done

/bin/echo '[ゲーム開始]'
while read -p "> ゲームの説明を聞きますか? [y/n] " yes_or_no ; do
    case ${yes_or_no} in
        [Yy]|[Yy][Ee][Ss] )
            show_game_infomation
            break
        ;;

        [Nn]|[Nn][Oo] )
            /bin/echo
            /bin/echo '説明をスキップします。'
            break
        ;;

        * )
            /bin/echo
            /bin/echo "> yes か no かでこたえてほしいのです!"
        ;;
    esac
done
/bin/echo
/bin/echo '[ファイルを生成中]'

/bin/echo -n .
mkdir START

num_first_max=5
num_second_max=5

# first
for i in `seq 1 ${num_first_max}`
do
    /bin/echo -n .
    mkdir "START/tobira_${i}"
done

# first
for i in `seq 1 ${num_first_max}`
do
    # second
    for j in `seq 1 ${num_second_max}`
    do
    /bin/echo -n .
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
    /bin/echo -n .
    pooh_friend_dir_num_first=$(($RANDOM % $num_first_max + 1))
    pooh_friend_dir_num_second=$(($RANDOM % $num_second_max + 1))
    # hiraite.txt（ドクロとポーさん）と重複しないファイル名にする。
    cp "items/pooh-friend-${i}.txt" "START/tobira_${pooh_friend_dir_num_first}/tobira_${pooh_friend_dir_num_first}_${pooh_friend_dir_num_second}/friend-${i}.txt"
    # /bin/echo
    # /bin/echo "デバッグ"
    # /bin/echo "friend-${i}:  ${pooh_friend_dir_num_first}, ${pooh_friend_dir_num_second}"
done

# /bin/echo
# /bin/echo "デバッグ"
# /bin/echo "dokuro : ${dokuro_dir_num_first}, ${dokuro_dir_num_second}"
# /bin/echo "pooh : ${pooh_dir_num_first}, ${pooh_dir_num_second}"

/bin/echo
/bin/echo
Wait '■ ヒント１'
/bin/echo
/bin/echo "> まずは下のコマンドを使って、START ディレクトリに移動をしてみてね"
/bin/echo '========================================'
/bin/echo '  | コマンド    |           説明'
/bin/echo '========================================'
/bin/echo '1 | pwd         | 自分がいる場所を表示'
/bin/echo '----------------------------------------'
/bin/echo '2 | ls          | 存在するファイルを表示'
/bin/echo '----------------------------------------'
/bin/echo '3 | cd          | 自分の場所を移動'
/bin/echo '----------------------------------------'
/bin/echo '4 | cat         | ファイルの中身確認'
/bin/echo '----------------------------------------'
/bin/echo '5 | mv          | ファイルを移動'
/bin/echo '----------------------------------------'
/bin/echo '6 | rm          | ファイルを削除'
/bin/echo '========================================'
/bin/echo
Wait '■ ヒント２'
/bin/echo
/bin/echo "> ミッションが終わったら下のコマンドでゴールだよ！"
/bin/echo '========================================'
/bin/echo '  | コマンド    |           説明'
/bin/echo '========================================'
/bin/echo '1 | sh end.sh   | 終了スクリプト実行'
/bin/echo '========================================'
/bin/echo
/bin/echo
Wait '> 最初は、ヒントをよく確認しならがら進めてみよう！'
/bin/echo
Wait '> 今から時間をはかるよ、、、よーいスタート！'
/bin/echo

/bin/echo $user_name > user_name_tmp
/bin/echo -n `date +%s` > user_time_tmp