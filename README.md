# **Fuori Nevica**

Un progetto per il corso di **Distributed Systems**. Questo repository contiene l'intero progetto e la relativa presentazione. L'applicazione è destinata ai camerieri di un ristorante, che possono usarla sui loro dispositivi Android per prendere ordinazioni ai tavoli. Utilizza l'algoritmo di **Ricart-Agrawala** per garantire l'accesso concorrente sicuro a un web server che gestisce un database di ingredienti.

## **Indice**
- [Descrizione](#descrizione)
- [Requisiti](#requisiti)
- [Installazione](#installazione)
- [Uso](#uso)
- [Contributi](#contributi)
- [Licenza](#licenza)
- [Contatti](#contatti)

---

## **Descrizione**
**Fuori Nevica** è un'applicazione mobile sviluppata per dispositivi Android, pensata per permettere ai camerieri di prendere le ordinazioni in un ristorante. L'app comunica con un **web server** che gestisce un database degli ingredienti disponibili per ciascun piatto. 

L'app implementa l'algoritmo di **Ricart-Agrawala**, un algoritmo di **mutua esclusione** che garantisce che solo un cameriere alla volta possa accedere al server per modificare i dati degli ingredienti, evitando conflitti tra richieste simultanee.

L'uso di questo algoritmo assicura che le operazioni di aggiornamento del database siano coerenti, anche quando più camerieri cercano di accedere contemporaneamente alle stesse risorse.

---

## **Requisiti**
Prima di iniziare, assicurati di avere installato quanto segue:

- **Android Studio** (o altro IDE compatibile con Android)
- **Java 8+** o **Kotlin** (per lo sviluppo dell'app Android)
- **Node.js** (per il server backend)
- **MySQL** o **PostgreSQL** (per il database degli ingredienti)
- **Sistema operativo**: Android per l'app, qualsiasi sistema operativo per il server (Linux, Windows, macOS)
- **Connessione di rete** per la comunicazione tra l'app e il server.

---


## **Installazione**
Segui questi passaggi per configurare il progetto sul tuo ambiente locale:

1. Clona il repository:
   ```bash
   git clone https://github.com/nozzolillo01/fuori-nevica.git
   cd fuori-nevica
   ```

2. Installa le dipendenze:
   ```bash
   [istruzione per installare le dipendenze, es. npm install, pip install -r requirements.txt]
   ```

3. Configura il progetto (se necessario):
   - [Aggiungi i dettagli per eventuali configurazioni, es. file `.env`]

4. Avvia il progetto:
   ```bash
   [comando per avviare il progetto, es. npm start, python main.py]
   ```

---

## **Uso**
Per utilizzare il progetto:
- [Passo 1: Istruzioni su come avviare/visualizzare il progetto]
- [Passo 2: Esempio di comando o uso specifico]
- [Passo 3: Altri dettagli rilevanti]

---

## **Contributi**
Contributi, bug report e richieste di funzionalità sono benvenuti!

Per contribuire:
1. Fai un fork del progetto.
2. Crea un nuovo branch:
   ```bash
   git checkout -b feature/nuova-funzionalità
   ```
3. Fai le modifiche e fai un commit:
   ```bash
   git commit -m "Aggiunta nuova funzionalità"
   ```
4. Fai un push al branch:
   ```bash
   git push origin feature/nuova-funzionalità
   ```
5. Apri una pull request.

---

## **Licenza**
Questo progetto è distribuito sotto la licenza [specifica licenza, es. MIT, GPL, ecc.]. Vedi il file `LICENSE` per i dettagli.

---

## **Contatti**
Per domande o ulteriori informazioni:
- **Email:** [tuo.email@example.com]
- **GitHub:** [https://github.com/nozzolillo01](https://github.com/nozzolillo01)

