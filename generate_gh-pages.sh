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

mogrify -path $TMP_WORK_DIR -format png -background white bkchem/*.svg
#ls -lahF $TMP_WORK_DIR

# create thumbs
mkdir $TMP_WORK_DIR/thumbs
mogrify  -path $TMP_WORK_DIR/thumbs -format png  -thumbnail 25% $TMP_WORK_DIR/*.png

# create index.html
INDEX_HTML=$TMP_WORK_DIR/index.html
echo '<html>' > $INDEX_HTML
echo '    <body style="background-color:#000000">' >> $INDEX_HTML
echo '    <a href="https://github.com/mbohun/molecules" style="color:#ffffff">' >> $INDEX_HTML
echo '        <h1 style="color:#ffffff">mbohun.github.io/molecules</h1>' >> $INDEX_HTML
echo '    </a>' >> $INDEX_HTML
for img in `ls $TMP_WORK_DIR/*.png`
do
    b_img=`basename $img`
    echo "    <a href=\"${b_img}\"><img src=\"thumbs/${b_img}\" title=\"${b_img%.*}\"/></a>" >> $INDEX_HTML
done

echo '    </body>' >> $INDEX_HTML
echo '</html>' >> $INDEX_HTML

BKCHEM_GIT_SHA=`git log -n1 --format=format:%H bkchem`

git checkout gh-pages

git rm -r thumbs *.png index.html
cp -r $TMP_WORK_DIR/* .
git add .

git commit -m"AUTO: regenerated branch gh-pages from master (${BKCHEM_GIT_SHA})."
git push --set-upstream origin gh-pages

git checkout master

# cleanup
#rm -rf $TMP_WORK_DIR
