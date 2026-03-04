import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import userRoutes from './routes/userRoutes';
import { errorHandler } from './middlewares/errorHandler';

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json({ type: 'application/json', charset: 'utf-8' }));

app.use('/users', userRoutes);

app.use(errorHandler);

export default app;