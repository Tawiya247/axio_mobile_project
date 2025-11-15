const jwt = require('jsonwebtoken');
const { prisma } = require('../config/database');

// Middleware pour vérifier le token JWT
const auth = async (req, res, next) => {
  try {
    // Récupérer le token du header Authorization
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authentification requise. Veuillez vous connecter.'
      });
    }

    const token = authHeader.split(' ')[1];

    // Vérifier le token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Vérifier si l'utilisateur existe toujours
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        email: true,
        created_at: true
      }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Le compte associé à ce token n\'existe plus.'
      });
    }

    // Ajouter l'utilisateur à la requête
    req.user = user;
    req.userId = user.id;

    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Session expirée. Veuillez vous reconnecter.'
      });
    }
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Token invalide. Veuillez vous reconnecter.'
      });
    }

    console.error('Erreur d\'authentification:', error);
    res.status(500).json({
      success: false,
      message: 'Une erreur est survenue lors de l\'authentification.'
    });
  }
};

// Middleware pour les rôles (à étendre selon les besoins)
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Vous n\'avez pas les autorisations nécessaires pour accéder à cette ressource.'
      });
    }
    next();
  };
};

module.exports = {
  auth,
  authorize
};
