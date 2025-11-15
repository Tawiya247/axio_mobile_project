const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
  errorFormat: 'pretty',
});

// Fonction pour se connecter à la base de données
const connectDB = async () => {
  try {
    await prisma.$connect();
    console.log('✅ Connecté à la base de données avec succès');
    return prisma;
  } catch (error) {
    console.error('❌ Erreur de connexion à la base de données:', error);
    process.exit(1);
  }
};

// Fonction pour fermer la connexion à la base de données
const disconnectDB = async () => {
  try {
    await prisma.$disconnect();
    console.log('✅ Déconnecté de la base de données');
  } catch (error) {
    console.error('❌ Erreur lors de la déconnexion de la base de données:', error);
    process.exit(1);
  }
};

module.exports = {
  prisma,
  connectDB,
  disconnectDB,
};
