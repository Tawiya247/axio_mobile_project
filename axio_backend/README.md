# Axio Backend

Backend pour l'application Axio - Gestion de dépenses personnelles avec IA

## Prérequis

- Node.js 18+
- MySQL 8.0+
- XAMPP (pour MySQL)
- Compte Google Cloud avec l'API Gemini activée

## Installation

1. Cloner le dépôt
2. Installer les dépendances :

```bash
npm install
```

3. Copier le fichier `.env.example` vers `.env` et configurer les variables d'environnement :

```bash
cp .env.example .env
```

4. Démarrer les services MySQL via XAMPP
5. Lancer la migration de la base de données :

```bash
npx prisma migrate dev --name init
```

## Démarrage

En mode développement :

```bash
npm run dev
```

En production :

```bash
npm start
```

## Structure du Projet

```
src/
├── config/          # Configuration de l'application
├── controllers/     # Contrôleurs pour les routes
├── middlewares/     # Middlewares personnalisés
├── models/          # Modèles de données (générés par Prisma)
├── routes/          # Définition des routes
├── services/        # Logique métier
├── utils/           # Utilitaires
└── validators/      # Validation des données
```

## API Documentation

### Authentification

- `POST /api/auth/register` - Inscription d'un nouvel utilisateur
- `POST /api/auth/login` - Connexion d'un utilisateur
- `GET /api/auth/profile` - Profil de l'utilisateur connecté

### Dépenses

- `GET /api/expenses` - Liste des dépenses
- `POST /api/expenses` - Créer une dépense
- `GET /api/expenses/:id` - Détails d'une dépense
- `PUT /api/expenses/:id` - Mettre à jour une dépense
- `DELETE /api/expenses/:id` - Supprimer une dépense

### Portefeuilles

- `GET /api/wallets` - Liste des portefeuilles
- `POST /api/wallets` - Créer un portefeuille
- `GET /api/wallets/:id` - Détails d'un portefeuille
- `PUT /api/wallets/:id` - Mettre à jour un portefeuille
- `DELETE /api/wallets/:id` - Supprimer un portefeuille

### Objectifs

- `GET /api/goals` - Liste des objectifs
- `POST /api/goals` - Créer un objectif
- `GET /api/goals/:id` - Détails d'un objectif
- `PUT /api/goals/:id` - Mettre à jour un objectif
- `DELETE /api/goals/:id` - Supprimer un objectif

## Tests

```bash
npm test
```

## Déploiement

1. Configurer les variables d'environnement de production
2. Construire l'application :

```bash
npm run build
```

3. Démarrer le serveur :

```bash
npm start
```

## Licence

MIT
