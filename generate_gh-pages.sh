#!/bin/bash
set -e

#
# NOTE: this script can be installed:
#       - as a commit hook, or
#       - as a build script (for eaxmple run on travis-ci.org, circleci.com, Jenkins, etc.)
#
PROGRAM_NAME="`basename ${0}`"

TMP_WORK_DIR=`mktemp -d /tmp/${PROGRAM_NAME}.XXXXXX`
echo $TMP_WORK_DIR

BKCHEM_GIT_SHA=`git log -n1 --format=format:%H bkchem`

function generate_gh-pages {
    mogrify -path $TMP_WORK_DIR -format png -background white bkchem/*.svg
    #ls -lahF $TMP_WORK_DIR

    # create thumbs
    mkdir $TMP_WORK_DIR/thumbs
    mogrify  -path $TMP_WORK_DIR/thumbs -format png  -thumbnail 25% $TMP_WORK_DIR/*.png

    # create index.html
    local index_html=$TMP_WORK_DIR/index.html

    echo '<html>' > $index_html
    echo '    <body style="background-color:#000000">' >> $index_html
    echo '        <a href="https://github.com/mbohun/molecules" style="color:#ffffff; font-size:42px; text-decoration:none">mbohun.github.io/molecules</a>' >> $index_html
    echo '        <p/>' >> $index_html
    echo "        <a href=\"https://github.com/mbohun/molecules/tree/${BKCHEM_GIT_SHA}/bkchem\" style=\"color:#aaaaaa; text-decoration:none\">${BKCHEM_GIT_SHA}</a>" >> $index_html
    echo '        <p/>' >> $index_html

    for img in `ls $TMP_WORK_DIR/*.png`
    do
	local b_img=`basename $img`
	echo "    <a href=\"${b_img}\"><img src=\"thumbs/${b_img}\" title=\"${b_img%.*}\"/></a>" >> $index_html
    done

    echo '    </body>' >> $index_html
    echo '</html>' >> $index_html
}

function push_gh-pages {
    git checkout gh-pages

    git rm -r thumbs *.png index.html
    cp -r $TMP_WORK_DIR/* .
    git add .

    git commit -m"AUTO: regenerated branch gh-pages from master (${BKCHEM_GIT_SHA})."
    git push --set-upstream origin gh-pages

    git checkout master
}

while getopts ":p" opt; do
    case $opt in
	p)
	    generate_gh-pages
	    push_gh-pages
	    exit 0
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
    esac
done

# NOTE: unless the user asked to push gh-pages (-p) we just generate HTML and exit
generate_gh-pages

# cleanup
#rm -rf $TMP_WORK_DIR
