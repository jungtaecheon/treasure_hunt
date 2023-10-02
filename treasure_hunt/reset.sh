#!/bin/bash

rm -rf START 2>/dev/null

rm user_name_tmp 2>/dev/null
rm user_time_tmp 2>/dev/null

rm hiraite.txt 2>/dev/null

if [ $# -ne 0 ] && [ "$1" = 'auto_exec' ]; then
    # ゲームスタート時
    echo
else
    # 手動でresetスクリプト実行時
    while read -r -p "> 記録もすべて削除しますか? [y/n] " yes_or_no; do
        case ${yes_or_no} in
        [Yy] | [Yy][Ee][Ss])
            rm record.txt 2>/dev/null
            echo '記録をすべて削除しました。'
            break
            ;;

        [Nn] | [Nn][Oo])
            echo
            break
            ;;

        *)
            echo
            echo "> yes か no かでこたえてほしいのです!"
            ;;
        esac
    done
    echo 'ゲームをリセットしました。'
fi
