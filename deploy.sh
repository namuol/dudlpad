mkdir tmp
cp -r live_test.html docs lib tmp/.
git checkout gh-pages
rm -rf docs lib index.html
mv tmp/* .
rm -rf tmp
mv live_test.html index.html
git commit -am "auto-deployed to GitHub"
git push origin gh-pages
git checkout master
