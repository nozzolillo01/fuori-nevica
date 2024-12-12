from flask import Flask, request, jsonify
import sqlite3
import json

app = Flask(__name__)

# Inizializza il database
def init_db():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS ingredienti (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            qta INTEGER NOT NULL
        )
    ''')
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS camerieri (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            indirizzo TEXT NOT NULL,
            nome TEXT
        )
    ''')
    conn.commit()
    conn.close()

#popola la tabella ingredienti con i dati dal file JSON
def populate_ingredienti():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('SELECT COUNT(*) FROM ingredienti')
    if cursor.fetchone()[0] == 0:
        with open('ingredienti.json', 'r', encoding='utf-8') as f:
            ingredienti = json.load(f)
            for ingrediente in ingredienti:
                cursor.execute('INSERT INTO ingredienti (nome, qta) VALUES (?, ?)', (ingrediente['nome'], ingrediente['qta']))
        conn.commit()
    conn.close()

# Endpoint per ottenere tutti gli utenti
@app.route('/ingredienti', methods=['GET'])
def get_ingredienti():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM ingredienti')
    ingredienti = cursor.fetchall()
    conn.close()
    return jsonify(ingredienti)

# Endpoint per ottenere tutti i camerieri
@app.route('/camerieri', methods=['GET'])
def get_camerieri():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM camerieri')
    camerieri = cursor.fetchall()
    conn.close()
    return jsonify(camerieri)

#post per decrementare le quantità di vari ingredienti
@app.route('/order', methods=['POST'])
def update_ingredienti():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    data = request.json

    insufficient_pizzas = {}
    current_qtas = {}
    
    for pizza in data:
        ingredienti = list(data[pizza])

        for ingrediente in ingredienti:
            if(ingrediente in current_qtas):
                available_qta = current_qtas[ingrediente]
            else:
                cursor.execute('SELECT qta FROM ingredienti WHERE nome = ?', (ingrediente,))
                available_qta = cursor.fetchone()[0]
           
            if(available_qta < 1):
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
            cursor.execute('''
                UPDATE ingredienti
                SET qta = qta - ?
                WHERE nome = ?
            ''', (1, ingrediente))
    
    conn.commit()
    conn.close()
    return "OK", 200

# Endpoint per inserire un nuovo cameriere
@app.route('/camerieri/register', methods=['POST'])
def add_cameriere():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    data = request.json
    cursor.execute('INSERT INTO camerieri (indirizzo, nome) VALUES (?, ?)', (data['address'], data['name']))
    conn.commit()
    new_id = cursor.lastrowid
    cursor.execute('SELECT * FROM camerieri WHERE id = ?', (new_id,))
    new_cameriere_data = cursor.fetchone()
    new_cameriere = {
        'id': new_cameriere_data[0],
        'indirizzo': new_cameriere_data[1],
        'nome': new_cameriere_data[2]
    }
    conn.close()
    #TODO handle errors
    return jsonify(new_cameriere)

if __name__ == '__main__':
    init_db()
    populate_ingredienti()
    app.run(host='0.0.0.0', port=5000)
