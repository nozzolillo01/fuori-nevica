import json
import sqlite3
from flask import Flask, redirect, url_for
from api.api_routes import api_bp
from admin.admin_routes import admin_bp

app = Flask(__name__)
app.register_blueprint(api_bp, url_prefix='/api')
app.register_blueprint(admin_bp, url_prefix='/admin')

def init_db():
    conn = sqlite3.connect('static/database.db')
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
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dispositivo TEXT NOT NULL,
            messaggio TEXT
        )
    ''')
    conn.commit()

    cursor.execute('SELECT COUNT(*) FROM ingredienti')
    if cursor.fetchone()[0] == 0:
        with open('ingredienti.json', 'r', encoding='utf-8') as ingredienti:
            for ingrediente in json.load(ingredienti):
                cursor.execute('INSERT INTO ingredienti (nome, qta) VALUES (?, ?)', (ingrediente['nome'], ingrediente['qta']))
        conn.commit()

    conn.close()

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)
