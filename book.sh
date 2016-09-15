#!/bin/bash

book_url='http://www.biquge.la/book/1994/'
chapter_url='chapter_urls'
final_book='book'
rm -rf $chapter_url
rm -rf $final_book

get_single_chapter() {
	cpurl=$1
	echo $cpurl
	curl $cpurl | pup 'div[class="bookname"] h1, div#content json{}' | jq ".[0].text, .[1].text" | sed -e 's/^"//' | sed -e 's/"$//' >> $final_book
	last_line=`tail -1 $final_book`
	while true
	do
		if [ "$last_line"x = "null"x ]; then
			sleep 44
			echo "retry $cpurl"
			curl $cpurl | pup 'div[class="bookname"] h1, div#content json{}' | jq ".[0].text, .[1].text" | sed -e 's/^"//' | sed -e 's/"$//' >> $final_book
			last_line=`tail -1 $final_book`
		else
			break
		fi
	done
}

curl $book_url | pup 'div#list json{}' | jq ".[0].children[0].children[].children[].href" | tr -d '"'> $chapter_url
while read line; do
	cpurl=${book_url}${line}
	get_single_chapter $cpurl
	sleep 15
done < $chapter_url
sed '2~2s/\ /\n/g' $final_book > $final_book
