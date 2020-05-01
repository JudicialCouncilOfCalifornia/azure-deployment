# Build image
% docker build -t source/solr:8.5 .

# Run locally
% docker run -p 8983:8983 source/solr:8.5 solr-precreate jcc-trialcourt-prod /opt/solr/server/solr/configsets/solr_8.x_config
