#!/bin/sh
RSS_DIR="${HOME}/.feed"
TEMP_FILE=${RSS_DIR}'/.tmp'
TITLE_FILE=${RSS_DIR}'/title'
ITEM_FILE=${RSS_DIR}'/.item_view'
SUBCRIPTION=''
LAST_SUBSCRIPTION=''
NOW_PAGE='Welcome'
welcome="      //////          /////////       /////////\n     /      /	       /               /\n    /      /         /               /\n   ///////           ////////        ////////\n  /      /                  /               /\n /        /                /               /\n/          /      /////////       /////////\n"
mkdir ${RSS_DIR} > /dev/null 2>&1
Welcome(){
    env dialog --clear --title 'My Rss Reader' --ok-label '按我!!!' --msgbox "${welcome}" 0 0 
    NOW_PAGE='Menu'
}
Menu(){
    env dialog --clear --menu 'Choose Action' 0 0 5 'R' 'Read - read subscribed feeds' 'S' 'Subscribe - new subscription' 'D' 'Delete - delete subscription' 'U' 'Update - update subscription' 'Q' 'Bye' 2>${TEMP_FILE}
    action=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    case ${action} in
	'R')
	    NOW_PAGE='Read';;
	'S')
	    NOW_PAGE='Subscribe';;
	'D')
	    NOW_PAGE='Delete';;
	'U')
	    NOW_PAGE='Update';;
	'Q')
	    NOW_PAGE='Quit';;
    esac
}
Read(){
    s=''
    flag='1'
    cnt='1'
    while read line ; do
	if [ ${#line} -eq 0 ] ; then
	    return
	fi
	if [ $flag -eq 1 ] ; then
	    s=${s}' '${cnt}' '\""${line}"\"' '
	    flag='0'
	    eval TITLE_NAME$cnt='${line}'
	    cnt=$((${cnt} + 1))
	else
	    flag='1'
	fi
    done < ${TITLE_FILE}
    if [ ${#s} -eq 0 ] ; then 
	env dialog --clear --title 'Read' --msgbox 'No Subscription' 0 0 
	NOW_PAGE='Menu'
	return 
    fi
    eval env dialog --clear --title \'Read\' --menu \'choose subscription\' 0 0 $(($cnt - 1)) ${s} 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then 
	NOW_PAGE='Menu'
	return
    fi
    SUBSCRIPTION=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    eval SUBSCRIPTION=\$TITLE_NAME$SUBSCRIPTION
    NOW_PAGE='ReadItems'
}
ReadItems(){

    if ! [ -e "${RSS_DIR}/${SUBSCRIPTION}" ] ; then 
	dialog --clear --title 'ReadItems' --msgbox 'Please update first' 0 0 
	NOW_PAGE='Read'
	return
    fi
    if [ "${SUBSCRIPTION}" != "${LAST_SUBSCRIPTION}" ] ; then
	LAST_SUBSCRIPTION="${SUBSCRIPTION}"
	ri_flag=1
	ri_cnt=1
	ri_s=''
	while read line ; do
	    if [ ${ri_flag} -eq 1 ] ; then
		eval SUBTITLE${ri_cnt}='${line}'
		ri_s=${ri_s}' '${ri_cnt}' '\""${line}"\"' '
		ri_flag=2
	    elif [ ${ri_flag} -eq 2 ] ; then
		eval URL${ri_cnt}='${line}'
		ri_flag=3
	    else
		eval CONTENT${ri_cnt}=\""${line}"\"
		ri_cnt=$((${ri_cnt} + 1))
		ri_flag=1
	    fi
	done < ${RSS_DIR}'/'${SUBSCRIPTION}
    fi
    eval env dialog --clear --title \'Read\' --menu \'choose item\' 0 0 $((${ri_cnt} - 1)) ${ri_s} 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then
	NOW_PAGE='Read'
	return
    fi
    itemno=$(env cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    eval IN_TITLE=\$SUBTITLE${itemno}
    eval IN_URL=\$URL${itemno}
    eval IN_CONTENT=\$CONTENT${itemno}
    NOW_PAGE='Items'
}
Items(){
    echo "${IN_TITLE}" > ${ITEM_FILE}
    echo '==============================================' >> ${ITEM_FILE}
    echo "${IN_URL}" >> ${ITEM_FILE}
    echo '==============================================' >> ${ITEM_FILE}
    cnt=0
    for i in ${IN_CONTENT} ; do
	echo -n "${i} " >> ${ITEM_FILE}
	cnt=$((${cnt} + ${#i}))
	if [ ${cnt} -gt 70 ] ; then
	    echo '' >>${ITEM_FILE}
	    cnt=0
	fi
    done
    if [ ${cnt} -ne 0 ] ; then 
	echo '' >> ${ITEM_FILE}
    fi
    echo '==============================================' >> ${ITEM_FILE}
    env dialog --clear --textbox ${ITEM_FILE} 0 0
    NOW_PAGE='ReadItems'
}
Subscribe(){
    env dialog --clear --inputbox 'Enter feed url' 0 0 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then
	NOW_PAGE='Menu'
	return
    fi
    url=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    if [ ${#url} -eq 0 ] ; then
	env dialog --clear --title 'Subscribe' --msgbox 'url can not be empty' 0 0
	return
    fi
    env python3 myfeed.py -a $url
    res=$(env cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    if [ ${#res} -eq 0 ] ; then
	env dialog --clear --title 'Subscribe' --msgbox 'Success' 0 0
	NOW_PAGE='Menu'
    else
	env dialog --clear --title 'Subscribe' --msgbox 'Something Wrong' 0 0
    fi
}
Delete(){
    s=''
    flag='1'
    cnt='1'
    while read line ; do
	if [ $flag -eq 1 ] ; then
	    s=${s}' '${cnt}' '\""${line}"\"' '
	    flag='0'
	    eval TITLE_NAME$cnt='${line}'
	    cnt=$((${cnt} + 1))
	else
	    flag='1'
	fi
    done < ${TITLE_FILE}
    if [ ${#s} -eq 0 ] ; then 
	env dialog --clear --title 'Delete' --msgbox 'No Subscription' 0 0
	NOW_PAGE='Menu'
	return 
    fi
    eval env dialog --clear --title \'Delete\' --menu \'choose item to delete\' 0 0 ${cnt} ${s} 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then 
	NOW_PAGE='Menu'
	return
    fi
    SUBSCRIPTION=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    eval SUBSCRIPTION=\$TITLE_NAME$SUBSCRIPTION
    env python3 myfeed.py -d "$SUBSCRIPTION"
    tmp=$(cat ${TEMP_FILE})
    if [ ${#tmp} -eq 0 ] ; then
	env dialog --clear --title 'Delete' --msgbox 'OK' 0 0
    else
	env dialog --clear --title 'Delete' --msgbox 'Something Wrong' 0 0
    fi
}
Update(){
    s=''
    flag='1'
    cnt='1'
    while read line ; do
	if [ $flag -eq 1 ] ; then
	    s=${s}' '${cnt}' '\""${line}"\"' off '	    
	    flag='0'
	    eval TITLE_NAME$cnt='${line}'
	else
	    eval TITLE_URL$cnt='${line}'
	    cnt=$((${cnt} + 1))
	    flag='1'
	fi
    done < ${TITLE_FILE}
    if [ ${#s} -eq 0 ] ; then 
	env dialog --clear --title 'Update' --msgbox 'No Subscription' 0 0
	NOW_PAGE='Menu'
	return 
    fi
    eval env dialog --clear --title \'Update\' --checklist \'choose item to delete\' 0 0 ${cnt} ${s} 2>${TEMP_FILE}
    if [ $? -eq 1 ] ; then 
	NOW_PAGE='Menu'
	return
    fi
    SUBSCRIPTION=$(cat ${TEMP_FILE})
    env rm ${TEMP_FILE}
    cnt=0
    for i in $SUBSCRIPTION ; do
	cnt=$((${cnt} + 1))
    done
    OK=0
    no=1
    for i in $SUBSCRIPTION ; do
        eval tSUBSCRIPTION=\$TITLE_NAME$i
	eval tSUBSCRIPTIONURL=\$TITLE_URL$i
	env python3 myfeed.py -u $tSUBSCRIPTIONURL "$tSUBSCRIPTION"
	tmp=$(cat ${TEMP_FILE})
	env rm ${TEMP_FILE}
	if [ ${#tmp} -eq 0 ] ; then
	    echo $(((100 * ${no}) / ${cnt}))
	    echo "XXX"
	    echo "Please Wait Updating ${tSUBSCRIPTION}"
	    echo "XXX"
	    no=$((${no} + 1))
	else
	    OK=1
	    break
	fi
    done | env dialog --clear --title 'Update' --guage 'Please Wait' 20 70 0
    if [ ${OK} -eq 0 ] ; then 
	env dialog --clear --title 'Update' --msgbox 'Success' 0 0
    else
	env dialog --clear --title 'Update' --msgbox 'Something Wrong' 0 0
    fi
    NOW_PAGE='Menu'
}
Quit(){
    env dialog --clear --title 'Quit?' --yesno 'Do you want to quit?' 0 0
    tmp=$?
    if [ $tmp -eq 1 ] ; then
	NOW_PAGE='Menu'
    else
	NOW_PAGE='Exit'
    fi
}
while [ 1=1 ]; do
    case ${NOW_PAGE} in 
	'Welcome')
	    Welcome;;
	'Menu')
	    Menu;;
	'Read')
	    Read;;
	'ReadItems')
	    ReadItems;;
	'Items')
	    Items;;
	'Subscribe')
	    Subscribe;;
	'Update')
	    Update;;
	'Delete')
	    Delete;;
	'Quit')
	    Quit;;
	'Exit')
	    exit 0;;
    esac
done
