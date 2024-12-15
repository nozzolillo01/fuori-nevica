from flask import Blueprint, request, jsonify
import sqlite3

api_bp = Blueprint('api', __name__)

def get_db_connection():
    return sqlite3.connect('static/database.db')

@api_bp.route('/ingredienti', methods=['GET'])
def get_ingredienti():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute('SELECT * FROM ingredienti')
    ingredienti = cursor.fetchall()
    conn.close()
    
    return jsonify(ingredienti)

@api_bp.route('/camerieri', methods=['GET'])
def get_camerieri():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('SELECT * FROM camerieri')
    camerieri = cursor.fetchall()
    conn.close()

    return jsonify(camerieri)

@api_bp.route('/order', methods=['POST'])
def update_ingredienti():
    conn = get_db_connection()
    cursor = conn.cursor()
    data = request.json

    insufficient_pizzas = {}
    current_qtas = {}
    
    for pizza in data:
        ingredienti = list(data[pizza])

        for ingrediente in ingredienti:
            if ingrediente in current_qtas:
                available_qta = current_qtas[ingrediente]
            else:
                cursor.execute('SELECT qta FROM ingredienti WHERE nome = ?', (ingrediente,))
                available_qta = cursor.fetchone()[0] #TODO assicurarsi che l'ingrediente esiste
            
            if available_qta < 1:
                if pizza not in insufficient_pizzas:
                    insufficient_pizzas[pizza] = []

                insufficient_pizzas[pizza].append(f"{ingrediente} non disponibile")
            else:
                current_qtas[ingrediente] = available_qta - 1

    if insufficient_pizzas:
        conn.close()
        return jsonify(insufficient_pizzas), 400
    
    for pizza in data:
        for ingrediente in data[pizza]:
            cursor.execute('UPDATE ingredienti SET qta = qta - ? WHERE nome = ?', (1, ingrediente))
    
    conn.commit()
    conn.close()
    return "OK", 200

@api_bp.route('/log', methods=['POST'])
def log():
    conn = get_db_connection()
    cursor = conn.cursor()

    data = request.json
    cursor.execute('INSERT INTO logs (dispositivo, messaggio) VALUES (?, ?)', (data['dispositivo'], data['msg']))
    conn.commit()

    return "OK", 200

@api_bp.route('/logs', methods=['GET'])
def read_logs():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM logs')
    logs_raw = cursor.fetchall()
    
    logs = {}
    for log in logs_raw:
        device = log[1]
        if device in logs:
            logs[device].append(log[2])
        else:
            logs[device] = [log[2]]

    conn.commit()
    conn.close()

    return jsonify({"logs": logs})

@api_bp.route('/camerieri/register', methods=['POST'])
def add_cameriere():
    conn = get_db_connection()
    cursor = conn.cursor()

    data = request.json
    cursor.execute('INSERT INTO camerieri (indirizzo, nome) VALUES (?, ?)', (data['address'], data['name']))
    conn.commit()

    new_id = cursor.lastrowid
    cursor.execute('SELECT * FROM camerieri WHERE id = ?', (new_id,))
    new_cameriere_data = cursor.fetchone()
    conn.close()

    return jsonify({
        'id': new_cameriere_data[0],
        'indirizzo': new_cameriere_data[1],
        'nome': new_cameriere_data[2]
    })
