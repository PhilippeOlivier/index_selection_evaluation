# Start postgress etc
# See: https://dba.stackexchange.com/a/204089
pg_ctlcluster 12 main start
service postgresql restart

cd index_selection_evaluation

# Fix the dsdgen errors
cp ds-fix/* tpcds-kit/tools
cd tpcds-kit/tools
make OS=LINUX
cd ../..

# Fix the 2 remaining NoneType errors
# TODO at some point maybe

# Run the tests
python3 -m unittest discover tests
