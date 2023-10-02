#!/bin/bash

rm -rf START 2>/dev/null

rm user_name_tmp 2>/dev/null
rm user_time_tmp 2>/dev/null

rm hiraite.txt 2>/dev/null

if [ $1 != 'start' ]; then
    while read -p "> 記録もすべて削除しますか? [y/n] " yes_or_no; do
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
fi

echo 'データを初期化しました。'
