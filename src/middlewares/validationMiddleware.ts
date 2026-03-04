import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';

const registerSchema = Joi.object({
  fullName: Joi.string().min(3).max(100).required(),
  birthDate: Joi.date().required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  role: Joi.string().valid('ADMIN', 'USER').optional(),
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

const blockSchema = Joi.object({});

export const validateRegister = (req: Request, res: Response, next: NextFunction) => {
  const { error } = registerSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });
  next();
};

export const validateLogin = (req: Request, res: Response, next: NextFunction) => {
  const { error } = loginSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });
  next();
};

export const validateBlock = (req: Request, res: Response, next: NextFunction) => {
  const { error } = blockSchema.validate(req.body);
  if (error) return res.status(400).json({ error: error.details[0].message });
  next();
};