######## GIT HISTORY ########

mkdir /root/source
cp node_server/* /root/source
cd /root/source
git init
echo 'flag{G1t_H1st0ry_Secr3ts_L1VE_0N!}' > flag.txt
git add .

git config user.name "Anonymous"
git config user.email "Anonymous@email.com"

git commit -m "Initial commit"

rm flag.txt
git add .
git commit -m "Removed sensitive information"

echo -e "# Node Dev Portal v1.0.4\nTODO: Describe and show how to build your code and run the tests." > README.md
git add .
git commit -m "Added README.md"

cd -
zip -r /var/backups/source.zip /root/source 
chmod 644 /var/backups/source.zip