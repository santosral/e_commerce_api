# Wait for MongoDB to be ready
until mongosh --host mongodb:27017 --eval 'db.runCommand({ ping: 1 })'; do
  echo "Waiting for MongoDB to be ready..."
  sleep 2
done

# Initialize the replica set
mongosh --host mongodb:27017 --eval '
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "localhost:27017" }
  ]
})
'