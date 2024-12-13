from flask import Blueprint, render_template, request, redirect, url_for, flash
import sqlite3

admin_bp = Blueprint('admin', __name__)

def get_db_connection():
    return sqlite3.connect('static/database.db')

# Route principale per l'amministrazione
@admin_bp.route('/')
def admin_home():
    return render_template('index.html')

# Route per visualizzare e gestire gli ingredienti
@admin_bp.route('/ingredienti')
def gestisci_ingredienti():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('SELECT * FROM ingredienti')
    ingredienti = cursor.fetchall()
    conn.close()

    return render_template('ingredienti.html', ingredienti=ingredienti)

@admin_bp.route('/ingredienti/add', methods=['POST'])
def aggiungi_ingrediente():
    nome = request.form['nome']
    qta = request.form['qta']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('INSERT INTO ingredienti (nome, qta) VALUES (?, ?)', (nome, qta))
    conn.commit()
    conn.close()

    return redirect(url_for('admin.gestisci_ingredienti'))

@admin_bp.route('/ingredienti/edit/<int:id>', methods=['POST'])
def modifica_ingrediente(id):
    qta = request.form['qta']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE ingredienti SET qta = ? WHERE id = ?', (qta, id))
    conn.commit()
    conn.close()

    return redirect(url_for('admin.gestisci_ingredienti'))

@admin_bp.route('/ingredienti/delete/<int:id>', methods=['POST'])
def elimina_ingrediente(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('DELETE FROM ingredienti WHERE id = ?', (id,))
    conn.commit()
    conn.close()

    return redirect(url_for('admin.gestisci_ingredienti'))

# Route per visualizzare e gestire i camerieri
@admin_bp.route('/camerieri')
def gestisci_camerieri():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('SELECT * FROM camerieri')
    camerieri = cursor.fetchall()
    conn.close()

    return render_template('camerieri.html', camerieri=camerieri)

@admin_bp.route('/camerieri/edit/name/<int:id>', methods=['POST'])
def modifica_nome_cameriere(id):
    nome = request.form['nome']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE camerieri SET nome = ? WHERE id = ?', (nome, id))
    conn.commit()
    conn.close()

    return redirect(url_for('admin.gestisci_camerieri'))

@admin_bp.route('/camerieri/edit/address/<int:id>', methods=['POST'])
def modifica_addr_cameriere(id):
    ind = request.form['indirizzo']

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('UPDATE camerieri SET indirizzo = ? WHERE id = ?', (ind, id))
    conn.commit()
    conn.close()

    return redirect(url_for('admin.gestisci_camerieri'))

@admin_bp.route('/camerieri/reset/', methods=['POST'])
def reset_camerieri():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('DELETE FROM camerieri')
    cursor.execute('DELETE FROM sqlite_sequence WHERE name = "camerieri"')
    conn.commit()
    conn.close()

    return redirect(url_for('admin.gestisci_camerieri'))
