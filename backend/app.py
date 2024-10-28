from flask import Flask, request, jsonify
from sms_parser import parse_sms_list
from flask_pymongo import PyMongo
from bson import ObjectId


app = Flask(__name__)

# Configure the MongoDB URI
app.config["MONGO_URI"] = "mongodb+srv://groceryadmin:YUHzVnS5UC1XqqA6@grocery-cluster.uwe15mr.mongodb.net/grocery-cluster?retryWrites=true&w=majority&appName=grocery-cluster"
mongo = PyMongo(app)

# Database connection check
def initialize_db():
    try:
        # Attempt to read a document from a sample collection to check connection
        mongo.db.transactions.find_one()
        print("connected to db")
    except Exception as e:
        print(f"Error connecting to the database: {e}")

# Add this helper function to convert ObjectIds to strings
def json_serializer(data):
    """Converts ObjectId instances to strings for JSON serialization."""
    if isinstance(data, list):
        for item in data:
            if "_id" in item:
                item["_id"] = str(item["_id"])
    elif "_id" in data:
        data["_id"] = str(data["_id"])
    return data

@app.route('/parse-sms', methods=['POST'])
def parse_sms():
    """Endpoint to parse a list of SMS messages."""
    data = request.json  # Expecting a JSON body with 'sms_list' key

    if not data or 'sms_list' not in data:
        return jsonify({'error': 'Invalid input, expected JSON with "sms_list"'}), 400

    sms_list = data['sms_list']
    if not isinstance(sms_list, list):
        return jsonify({'error': '"sms_list" must be a list'}), 400

    try:
        parsed_data = parse_sms_list(sms_list)

        # Insert parsed data into MongoDB and get inserted document IDs
        insert_result = mongo.db.transactions.insert_many(parsed_data)
        print("inserted to db")
        
        # Update parsed_data with MongoDB IDs
        for record, insert_id in zip(parsed_data, insert_result.inserted_ids):
            record["_id"] = insert_id
        
        # Serialize ObjectId fields to strings
        json_serialized_data = json_serializer(parsed_data)
        
        return jsonify(json_serialized_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/print', methods=['GET'])
def print_hello():
    print("hello")  # This will print "hello" in the terminal
    return jsonify({"message": "Hello from Flask!"})

if __name__ == '__main__':
    # Run database initialization function before starting the server
    initialize_db()
    app.run(debug=True, host='0.0.0.0', port=5000)
