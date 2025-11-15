const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const { auth } = require('../middlewares/auth.middleware');
const validate = require('../middlewares/validate.middleware').validate;

const router = express.Router();

// Validation des données d'entrée
const validateRegister = [
  body('email')
    .isEmail()
    .withMessage('Veuillez fournir une adresse email valide')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Le mot de passe doit contenir au moins 8 caractères')
];

const validateLogin = [
  body('email')
    .isEmail()
    .withMessage('Veuillez fournir une adresse email valide')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Le mot de passe est requis')
];

// Routes d'authentification
router.post('/register', validateRegister, (req, res, next) => {
  validate(req, res, () => {
    authController.register(req, res, next);
  });
});

router.post('/login', validateLogin, (req, res, next) => {
  validate(req, res, () => {
    authController.login(req, res, next);
  });
});

router.get('/profile', auth, authController.getProfile);

module.exports = router;
