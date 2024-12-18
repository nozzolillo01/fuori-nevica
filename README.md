# **Fuori Nevica**

Un progetto per il corso di **Distributed Systems**. Questo repository contiene l'intero progetto e la relativa presentazione di un'applicazione, realizzata per il corso di Distributed System and IoT, destinata ai camerieri di un ipotetico ristorante, per prendere ordinazioni ai tavoli. Utilizza l'algoritmo di **Ricart-Agrawala** per garantire l'accesso concorrente sicuro a un web server che gestisce un database di ingredienti.


---

## **Descrizione**
**Fuori Nevica** è un'applicazione mobile sviluppata per dispositivi Android, pensata per permettere ai camerieri di prendere le ordinazioni in un ristorante. L'app comunica con un **web server** che gestisce un database degli ingredienti disponibili per ciascun piatto. 

L'app implementa l'algoritmo di **Ricart-Agrawala**, un algoritmo di **mutua esclusione** che garantisce che solo un cameriere alla volta possa accedere al server per modificare i dati degli ingredienti, evitando conflitti tra richieste simultanee.

L'uso di questo algoritmo assicura che le operazioni di aggiornamento del database siano coerenti, anche quando più camerieri cercano di accedere contemporaneamente alle stesse risorse.
