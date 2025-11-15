require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');

// Import des routes
const authRoutes = require('./routes/auth.routes');

// Initialisation de l'application Express
const app = express();

// Configuration CORS
const corsOptions = {
  origin: process.env.FRONTEND_URL || 'http://localhost:3001',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
};
app.use(cors(corsOptions));

// Middleware pour parser le JSON
app.use(express.json());

// Connexion à la base de données
const prisma = new PrismaClient({
  log: ['query', 'error', 'warn']
});

// Test de la connexion à la base de données
async function testDatabaseConnection() {
  try {
    await prisma.$connect();
    console.log('✅ Connecté à la base de données avec succès');
  } catch (error) {
    console.error('❌ Erreur de connexion à la base de données:', error);
    process.exit(1);
  }
}

// Routes
app.get('/', (req, res) => {
  res.json({ 
    success: true,
    message: 'API Axio - Gestion des dépenses personnelles',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Routes d'API
app.use('/api/auth', authRoutes);

// Gestion des routes non trouvées
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée',
    path: req.originalUrl
  });
});

// Gestion des erreurs globales
app.use((err, req, res, next) => {
  console.error('Erreur du serveur:', err);
  
  // Erreurs de validation
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      message: 'Erreur de validation des données',
      errors: err.errors
    });
  }

  // Erreur JWT
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      message: 'Token invalide ou expiré'
    });
  }

  // Erreur par défaut
  res.status(500).json({
    success: false,
    message: 'Une erreur est survenue sur le serveur',
    error: process.env.NODE_ENV === 'development' ? err.message : {}
  });
});

// Port d'écoute
const PORT = process.env.PORT || 3000;

// Démarrage du serveur
async function startServer() {
  try {
    await testDatabaseConnection();
    
    app.listen(PORT, () => {
      console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
      console.log(`📡 Environnement: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🌐 URL du frontend: ${process.env.FRONTEND_URL || 'http://localhost:3001'}`);
      console.log(`🛡️  Mode sécurisé: ${process.env.NODE_ENV === 'production' ? 'Activé' : 'Désactivé'}`);
    });
  } catch (error) {
    console.error('❌ Erreur lors du démarrage du serveur:', error);
    process.exit(1);
  }
}

// Gestion des erreurs non capturées
process.on('unhandledRejection', (err) => {
  console.error('Erreur non gérée (promesse rejetée):', err);
  process.exit(1);
});

process.on('uncaughtException', (err) => {
  console.error('Erreur non gérée (exception non capturée):', err);
  process.exit(1);
});

// Démarrer le serveur
if (process.env.NODE_ENV !== 'test') {
  startServer();
}

module.exports = app;
