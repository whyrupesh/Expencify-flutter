from flask import Flask, request, jsonify
from sms_parser import parse_sms_list

app = Flask(__name__)

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
        return jsonify(parsed_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500



@app.route('/print', methods=['GET'])
def print_hello():
    print("hello")  # This will print "hello" in the terminal
    return jsonify({"message": "Hello from Flask!"})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
