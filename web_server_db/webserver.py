from flask import Flask, request, jsonify
import sqlite3
import json

app = Flask(__name__)

# Inizializza il database
def init_db():
    #delete the database file
    import os
    if os.path.exists('database.db'):
        os.remove('database.db')
    
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
@app.route('/ingredienti/update', methods=['POST'])
def update_ingredienti():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    data = request.json
    insufficient_pizzas = {}
    
    for pizza in data:
        pizza_name = pizza['nome']
        for ingrediente in pizza['ingredienti']:
            cursor.execute('SELECT qta FROM ingredienti WHERE nome = ?', (ingrediente['nome'],))
            result = cursor.fetchone()
            if result is None:
                if pizza_name not in insufficient_pizzas:
                    insufficient_pizzas[pizza_name] = []
                insufficient_pizzas[pizza_name].append({'ingrediente': ingrediente['nome'], 'error': 'Ingrediente non trovato'})
                continue
            available_qta = result[0]
            if available_qta < ingrediente['qta']:
                if pizza_name not in insufficient_pizzas:
                    insufficient_pizzas[pizza_name] = []
                insufficient_pizzas[pizza_name].append({
                    'ingrediente': ingrediente['nome'],
                    'available': available_qta,
                    'requested': ingrediente['qta']
                })
    
    if insufficient_pizzas:
        conn.close()
        return jsonify({'error': 'Quantità insufficiente per alcune pizze', 'details': insufficient_pizzas}), 400
    
    for pizza in data:
        for ingrediente in pizza['ingredienti']:
            cursor.execute('''
                UPDATE ingredienti
                SET qta = qta - ?
                WHERE nome = ?
            ''', (ingrediente['qta'], ingrediente['nome']))
    
    conn.commit()
    conn.close()
    return jsonify({'message': 'Ingredienti aggiornati'})

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
