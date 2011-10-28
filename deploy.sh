mkdir tmp
cp -r live_test.html docs lib tmp/.
git checkout gh-pages
rm -rf docs lib index.html
mv tmp/* .
rm -rf tmp
git commit -am "auto-deployed to GitHub"
git push origin gh-pages
git checkout master
