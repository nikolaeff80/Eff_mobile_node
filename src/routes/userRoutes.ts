import express from 'express';
import * as userController from '../controllers/userController';
import { authenticate, isAdmin, isSelfOrAdmin } from '../middlewares/authMiddleware';
import { validateRegister, validateLogin, validateBlock } from '../middlewares/validationMiddleware';

const router = express.Router();

router.post('/register', validateRegister, userController.register);
router.post('/login', validateLogin, userController.login);
router.get('/:id', authenticate, isSelfOrAdmin, userController.getById);
router.get('/', authenticate, isAdmin, userController.getAll);
router.patch('/:id/block', authenticate, isSelfOrAdmin, validateBlock, userController.block);

export default router;