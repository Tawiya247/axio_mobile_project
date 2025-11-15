const { validationResult } = require('express-validator');

// Middleware pour gérer les erreurs de validation
const validate = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => ({
      field: error.param,
      message: error.msg
    }));

    return res.status(400).json({
      success: false,
      message: 'Erreur de validation',
      errors: errorMessages
    });
  }
  
  next();
};

module.exports = {
  validate
};
