#!/usr/bin/env python3

from flask import Flask, jsonify, request
import random

app = Flask(__name__)

coworking_spaces = [
    {"id": 1, "name": "Coworking Space A"},
    {"id": 2, "name": "Coworking Space B"},
    {"id": 3, "name": "Coworking Space C"}
]

@app.route("/api/coworking_spaces", methods=["GET"])
def get_coworking_spaces():
    return jsonify(coworking_spaces)

@app.route("/api/request_token", methods=["POST"])
def request_token():
    user_id = request.json.get("user_id")
    if not user_id:
        return jsonify({"error": "user_id is required"}), 400

    token = f"{user_id}-{random.randint(1000, 9999)}"
    return jsonify({"token": token})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
