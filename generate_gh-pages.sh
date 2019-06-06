#!/bin/bash
#
# NOTE: this script can be installed:
#       - as a commit hook, or
#       - as a build script (for eaxmple run on travis-ci.org, circleci.com, Jenkins, etc.)
#
PROGRAM_NAME="`basename ${0}`"
TMP_WORK_DIR=`mktemp -d /tmp/${PROGRAM_NAME}.XXXXXX`
echo $TMP_WORK_DIR

mogrify -path $TMP_WORK_DIR -format png -background white bkchem/*.svg
#ls -lahF $TMP_WORK_DIR

# create thumbs
mkdir $TMP_WORK_DIR/thumbs
mogrify  -path $TMP_WORK_DIR/thumbs -format png  -thumbnail 25% $TMP_WORK_DIR/*.png

# create index.html
INDEX_HTML=$TMP_WORK_DIR/index.html
echo '<html>' > $INDEX_HTML
echo '    <body style="background-color:#000000">' >> $INDEX_HTML
for img in `ls $TMP_WORK_DIR/*.png`
do
    b_img=`basename $img`
    echo "    <a href=\"${b_img}\"><img src=\"thumbs/${b_img}\" title=\"${b_img%.*}\"/></a>" >> $INDEX_HTML
done

echo '    </body>' >> $INDEX_HTML
echo '</html>' >> $INDEX_HTML

# git checkout -b gh-pages

# cleanup
#rm -rf $TMP_WORK_DIR
