import express from 'express';  // Usando ESM
import { initializeApp, credential, messaging } from 'firebase-admin';
import sgMail from '@sendgrid/mail';
import cron from 'node-cron';
import { join } from 'path';  // Correção para a importação do 'path'

// Inicializando o Firebase Admin com a chave do serviço
import serviceAccount from './path/to/serviceAccountKey.json'; // Ajuste o caminho correto

initializeApp({
  credential: credential.cert(serviceAccount),
  databaseURL: "https://n-valid-default-rtdb.firebaseio.com"
});

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

const app = express();
const port = process.env.PORT || 3000;

// Rota raiz ("/") para garantir que o servidor esteja funcionando
app.get('/', (req, res) => {
  res.status(200).send('Servidor Express está funcionando!');
});

// Para processar corpo JSON das requisições
app.use(express.json()); 

// Função de Envio Imediato de Notificação
app.post('/send-notification', async (req, res) => {
  const { token, title, body } = req.body;
  
  if (!token || !title || !body) {
    return res.status(400).send({ error: "Faltando dados para enviar notificação." });
  }

  const notificationMessage = {
    notification: {
      title,
      body,
    },
    token,
  };

  try {
    await messaging().send(notificationMessage);
    res.status(200).send({ message: 'Notificação enviada com sucesso!' });
  } catch (error) {
    console.error("Erro ao enviar notificação:", error);
    res.status(500).send({ error: `Erro ao enviar notificação. ${error}` });
  }
});

// Agendamento de envio diário de notificações
cron.schedule('0 5 * * *', sendDailyNotifications);

// Iniciar o servidor Express
app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
